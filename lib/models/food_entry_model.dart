import 'package:cloud_firestore/cloud_firestore.dart';

class FoodEntryModel {
  final String? id;
  final String name;
  final String category;
  final int portion;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final String mealType;      // breakfast | lunch | dinner | snack
  final DateTime createdAt;
  final bool estimatedByAI;

  FoodEntryModel({
    this.id,
    required this.name,
    this.category = 'Umum',
    this.portion = 1,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.mealType,
    DateTime? createdAt,
    this.estimatedByAI = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FoodEntryModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FoodEntryModel(
      id:            doc.id,
      name:          d['name']          ?? '',
      category:      d['category']      ?? 'Umum',
      portion:       d['portion']       ?? 1,
      calories:      d['calories']      ?? 0,
      carbs:         (d['carbs']        ?? 0).toDouble(),
      protein:       (d['protein']      ?? 0).toDouble(),
      fat:           (d['fat']          ?? 0).toDouble(),
      mealType:      d['mealType']      ?? 'snack',
      createdAt:     (d['createdAt'] as Timestamp).toDate(),
      estimatedByAI: d['estimatedByAI'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':          name,
    'category':      category,
    'portion':       portion,
    'calories':      calories,
    'carbs':         carbs,
    'protein':       protein,
    'fat':           fat,
    'mealType':      mealType,
    'createdAt':     Timestamp.fromDate(createdAt),
    'estimatedByAI': estimatedByAI,
  };
}