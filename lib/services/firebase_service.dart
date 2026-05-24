import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/food_entry_model.dart';
import '../models/activity_model.dart';
import '../models/weight_log_model.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  FirebaseService._init();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // ── Auth ──────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  // ── User Profile ──────────────────────────────────────
  Future<void> saveUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> userProfileStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // ── Food Entries ──────────────────────────────────────
  Future<void> addFoodEntry(String uid, FoodEntryModel entry) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('food_entries')
        .add(entry.toFirestore());
  }

  Future<void> deleteFoodEntry(String uid, String entryId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('food_entries')
        .doc(entryId)
        .delete();
  }

  Stream<List<FoodEntryModel>> foodEntriesStream(String uid, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _db
        .collection('users')
        .doc(uid)
        .collection('food_entries')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(FoodEntryModel.fromFirestore).toList());
  }

  // ── Activities ────────────────────────────────────────
  Future<void> addActivity(String uid, ActivityModel activity) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('activities')
        .add(activity.toFirestore());
  }

  Future<void> deleteActivity(String uid, String activityId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('activities')
        .doc(activityId)
        .delete();
  }

  Stream<List<ActivityModel>> activitiesStream(String uid, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _db
        .collection('users')
        .doc(uid)
        .collection('activities')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ActivityModel.fromFirestore).toList());
  }

  // ── Weight Logs ───────────────────────────────────────
  Future<void> addWeightLog(String uid, WeightLogModel log) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('weight_logs')
        .add(log.toFirestore());
  }

  Stream<List<WeightLogModel>> weightLogsStream(String uid, {int limit = 7}) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('weight_logs')
        .orderBy('loggedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(WeightLogModel.fromFirestore).toList());
  }

  // ── Weekly Food (untuk chart) ─────────────────────────
  Stream<List<FoodEntryModel>> weeklyFoodStream(String uid) {
    final start = DateTime.now().subtract(const Duration(days: 6));
    final startOfWeek = DateTime(start.year, start.month, start.day);
    return _db
        .collection('users')
        .doc(uid)
        .collection('food_entries')
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(FoodEntryModel.fromFirestore).toList());
  }
}