import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/database_helper.dart';

class AppProvider extends ChangeNotifier {
  UserModel _user = UserModel();
  bool _isLoggedIn = false;
  List<FoodEntry> _foodEntries = [];
  List<WeightEntry> _weightHistory = [];

  UserModel get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  List<FoodEntry> get foodEntries => _foodEntries;
  List<WeightEntry> get weightHistory => _weightHistory;

  // Fungsi Tambah Makanan
  Future<void> addFoodData(String name, String category, int portion, int calories, double carbs, double protein, double fat) async {
    final foodData = {
      'name': name,
      'category': category,
      'portion': portion,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'createdAt': DateTime.now().toIso8601String(), 
    };
    
    await DatabaseHelper.instance.insertFood(foodData);
    
    notifyListeners();
  }

  // Fungsi Tambah Aktivitas
  Future<void> addActivityData(String name, String intensity, int duration, int caloriesBurned) async {
    final activityData = {
      'name': name,
      'intensity': intensity,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    await DatabaseHelper.instance.insertActivity(activityData);
    notifyListeners();
  }

  // Calories consumed today
  int get caloriesEaten {
    final today = DateTime.now();
    return _foodEntries
        .where((e) =>
            e.time.day == today.day &&
            e.time.month == today.month &&
            e.time.year == today.year)
        .fold(0, (sum, e) => sum + e.calories);
  }

  // Calories burned (simplified: based on BMR)
  int get caloriesBurned {
    if (_user.targetCalories == 0) return 0;
    return (_user.targetCalories * 0.88).round();
  }

  // Macros today
  double get carbsToday {
    final today = DateTime.now();
    return _foodEntries
        .where((e) =>
            e.time.day == today.day &&
            e.time.month == today.month &&
            e.time.year == today.year)
        .fold(0.0, (sum, e) => sum + e.carbs);
  }

  double get proteinToday {
    final today = DateTime.now();
    return _foodEntries
        .where((e) =>
            e.time.day == today.day &&
            e.time.month == today.month &&
            e.time.year == today.year)
        .fold(0.0, (sum, e) => sum + e.protein);
  }

  double get fatToday {
    final today = DateTime.now();
    return _foodEntries
        .where((e) =>
            e.time.day == today.day &&
            e.time.month == today.month &&
            e.time.year == today.year)
        .fold(0.0, (sum, e) => sum + e.fat);
  }

  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void login(String email, String password) {
    _user.email = email;
    _isLoggedIn = true;
    _loadDemoData();
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _foodEntries.clear();
    notifyListeners();
  }

  void addFoodEntry(FoodEntry entry) {
    _foodEntries.add(entry);
    notifyListeners();
  }

  void _loadDemoData() {
    // Set demo user data
    _user = UserModel(
      name: 'Arya Permana',
      email: _user.email,
      gender: 'Laki-laki',
      weight: 110,
      height: 170,
      targetWeight: 80,
      birthDate: DateTime(2005, 6, 15),
    );

    // Load demo food entries
    final now = DateTime.now();
    _foodEntries = [
      FoodEntry(
        name: 'Nasi Putih',
        calories: 400,
        carbs: 80,
        protein: 8,
        fat: 1,
        time: now.subtract(const Duration(hours: 5)),
        mealType: 'lunch',
      ),
      FoodEntry(
        name: 'Ayam Bakar',
        calories: 350,
        carbs: 5,
        protein: 45,
        fat: 15,
        time: now.subtract(const Duration(hours: 4, minutes: 30)),
        mealType: 'lunch',
      ),
      FoodEntry(
        name: 'Sayur Bayam',
        calories: 60,
        carbs: 8,
        protein: 5,
        fat: 1,
        time: now.subtract(const Duration(hours: 4)),
        mealType: 'lunch',
      ),
      FoodEntry(
        name: 'Teh Manis',
        calories: 90,
        carbs: 22,
        protein: 0,
        fat: 0,
        time: now.subtract(const Duration(hours: 2)),
        mealType: 'snack',
      ),
      FoodEntry(
        name: 'Pisang',
        calories: 89,
        carbs: 23,
        protein: 1,
        fat: 0,
        time: now.subtract(const Duration(hours: 1)),
        mealType: 'snack',
      ),
      FoodEntry(
        name: 'Roti Tawar',
        calories: 132,
        carbs: 22,
        protein: 4,
        fat: 3,
        time: now.subtract(const Duration(hours: 8)),
        mealType: 'breakfast',
      ),
    ];

    // Load weight history
    _weightHistory = [
      WeightEntry(date: now.subtract(const Duration(days: 6)), weight: 110),
      WeightEntry(date: now.subtract(const Duration(days: 5)), weight: 110.2),
      WeightEntry(date: now.subtract(const Duration(days: 4)), weight: 109.5),
      WeightEntry(date: now.subtract(const Duration(days: 3)), weight: 109.8),
      WeightEntry(date: now.subtract(const Duration(days: 2)), weight: 110.5),
      WeightEntry(date: now.subtract(const Duration(days: 1)), weight: 109.3),
      WeightEntry(date: now, weight: 110),
    ];

    notifyListeners();
  }

  // Weekly nutrition data for chart
  List<Map<String, dynamic>> get weeklyNutrition {
    final days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    return List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final dayEntries = _foodEntries.where((e) =>
          e.time.day == date.day &&
          e.time.month == date.month &&
          e.time.year == date.year);
      return {
        'day': days[i],
        'calories': dayEntries.fold(0, (s, e) => s + e.calories),
        'carbs': dayEntries.fold(0.0, (s, e) => s + e.carbs),
        'protein': dayEntries.fold(0.0, (s, e) => s + e.protein),
        'fat': dayEntries.fold(0.0, (s, e) => s + e.fat),
      };
    });
  }
}
