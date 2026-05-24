import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/food_entry_model.dart';
import '../models/activity_model.dart';
import '../models/weight_log_model.dart';
import '../services/firebase_service.dart';
import '../providers/auth/auth_provider.dart';

class NutritionProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final _service = FirebaseService.instance;

  // ── State ─────────────────────────────────────────────
  bool _isEstimating = false;
  bool get isEstimating => _isEstimating;

  DateTime _selectedDate = DateTime.now();

  List<FoodEntryModel> _foodEntries = [];
  List<ActivityModel> _activities = [];
  List<WeightLogModel> _weightLogs = [];
  List<FoodEntryModel> _weeklyFood = [];

  StreamSubscription? _foodSub;
  StreamSubscription? _activitySub;
  StreamSubscription? _weightSub;
  StreamSubscription? _weeklySub;

  // ── Getters ───────────────────────────────────────────
  List<FoodEntryModel> get foodEntries => _foodEntries;
  List<ActivityModel> get activities => _activities;
  List<WeightLogModel> get weightLogs => _weightLogs;

  int get caloriesEaten =>
      _foodEntries.fold(0, (sum, e) => sum + e.calories);

  int get caloriesBurned =>
      _activities.fold(0, (sum, a) => sum + a.caloriesBurned);

  double get carbsToday =>
      _foodEntries.fold(0.0, (sum, e) => sum + e.carbs);

  double get proteinToday =>
      _foodEntries.fold(0.0, (sum, e) => sum + e.protein);

  double get fatToday =>
      _foodEntries.fold(0.0, (sum, e) => sum + e.fat);

  // Weekly nutrition: list of {date, calories} for chart
  // ✅ include protein/carbs/fat untuk NutritionChartWidget
  List<Map<String, dynamic>> get weeklyNutrition {
    final Map<String, Map<String, dynamic>> byDay = {};
    for (final entry in _weeklyFood) {
      final key = '${entry.createdAt.day}/${entry.createdAt.month}';
      if (byDay[key] == null) {
        byDay[key] = {
          'date': key,
          'calories': 0,
          'protein': 0.0,
          'carbs': 0.0,
          'fat': 0.0,
        };
      }
      byDay[key]!['calories'] = (byDay[key]!['calories'] as int) + entry.calories;
      byDay[key]!['protein']  = (byDay[key]!['protein']  as double) + entry.protein;
      byDay[key]!['carbs']    = (byDay[key]!['carbs']    as double) + entry.carbs;
      byDay[key]!['fat']      = (byDay[key]!['fat']      as double) + entry.fat;
    }
    return byDay.values.toList();
  }

  NutritionProvider(this._authProvider);

  String? get _uid => _authProvider.firebaseUser?.uid;

  // ── Init & Stream Setup ───────────────────────────────
  void init(String uid) {
    _cancelSubs();
    _listenDate(uid, _selectedDate);

    _weightSub = _service.weightLogsStream(uid).listen((logs) {
      _weightLogs = logs;
      notifyListeners();
    });

    _weeklySub = _service.weeklyFoodStream(uid).listen((food) {
      _weeklyFood = food;
      notifyListeners();
    });
  }

  void changeDate(DateTime date) {
    _selectedDate = date;
    final uid = _uid;
    if (uid == null) return;
    _cancelDateSubs();
    _listenDate(uid, date);
  }

  void _listenDate(String uid, DateTime date) {
    _foodSub = _service.foodEntriesStream(uid, date).listen((entries) {
      _foodEntries = entries;
      notifyListeners();
    });

    _activitySub = _service.activitiesStream(uid, date).listen((acts) {
      _activities = acts;
      notifyListeners();
    });
  }

  void _cancelDateSubs() {
    _foodSub?.cancel();
    _activitySub?.cancel();
  }

  void _cancelSubs() {
    _foodSub?.cancel();
    _activitySub?.cancel();
    _weightSub?.cancel();
    _weeklySub?.cancel();
  }

  @override
  void dispose() {
    _cancelSubs();
    super.dispose();
  }

  // ── CRUD ──────────────────────────────────────────────
  Future<void> addFood(FoodEntryModel entry) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.addFoodEntry(uid, entry);
  }

  Future<void> deleteFood(String entryId) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.deleteFoodEntry(uid, entryId);
  }

  Future<void> addActivity(ActivityModel activity) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.addActivity(uid, activity);
  }

  Future<void> deleteActivity(String activityId) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.deleteActivity(uid, activityId);
  }

  // ── AI: Estimasi Makanan ──────────────────────────────
  Future<FoodEntryModel?> estimateFoodWithAI(
      String foodName, String mealType) async {
    _setEstimating(true);
    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'YOUR_CLAUDE_API_KEY',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 400,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Estimasikan nilai gizi makanan Indonesia berikut: "$foodName".\n'
                  'Balas HANYA dengan JSON ini, tanpa teks lain:\n'
                  '{\n'
                  '  "name": "<nama makanan>",\n'
                  '  "category": "<kategori>",\n'
                  '  "calories": <int per 1 porsi>,\n'
                  '  "carbs": <float gram>,\n'
                  '  "protein": <float gram>,\n'
                  '  "fat": <float gram>\n'
                  '}',
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['content'][0]['text'] as String;
        final clean = text.replaceAll(RegExp(r'```json|```'), '').trim();
        final json = jsonDecode(clean) as Map<String, dynamic>;
        return FoodEntryModel(
          name: json['name'] ?? foodName,
          category: json['category'] ?? 'Umum',
          calories: (json['calories'] ?? 0) as int,
          carbs: (json['carbs'] ?? 0).toDouble(),
          protein: (json['protein'] ?? 0).toDouble(),
          fat: (json['fat'] ?? 0).toDouble(),
          mealType: mealType,
          estimatedByAI: true,
        );
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      _setEstimating(false);
    }
  }

  // ── AI: Estimasi Aktivitas ────────────────────────────
  Future<ActivityModel?> estimateActivityWithAI(
      String activityName, int duration, double weight) async {
    _setEstimating(true);
    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'YOUR_CLAUDE_API_KEY',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 300,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Estimasikan kalori yang terbakar:\n'
                  '- Aktivitas: "$activityName"\n'
                  '- Durasi: $duration menit\n'
                  '- Berat badan: ${weight.toStringAsFixed(0)} kg\n\n'
                  'Balas HANYA dengan JSON ini, tanpa teks lain:\n'
                  '{\n'
                  '  "name": "<nama aktivitas>",\n'
                  '  "intensity": "<ringan | sedang | berat>",\n'
                  '  "caloriesBurned": <int total kalori terbakar>\n'
                  '}',
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['content'][0]['text'] as String;
        final clean = text.replaceAll(RegExp(r'```json|```'), '').trim();
        final json = jsonDecode(clean) as Map<String, dynamic>;
        return ActivityModel(
          name: json['name'] ?? activityName,
          intensity: json['intensity'] ?? 'sedang',
          duration: duration,
          caloriesBurned: (json['caloriesBurned'] ?? duration * 7) as int,
          estimatedByAI: true,
        );
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      _setEstimating(false);
    }
  }

  void _setEstimating(bool val) {
    _isEstimating = val;
    notifyListeners();
  }
}