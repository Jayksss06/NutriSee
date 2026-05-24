import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String? id;
  final String name;
  final String intensity;   // ringan | sedang | berat
  final int duration;       // menit
  final int caloriesBurned;
  final DateTime createdAt;
  final bool estimatedByAI;

  ActivityModel({
    this.id,
    required this.name,
    required this.intensity,
    required this.duration,
    required this.caloriesBurned,
    DateTime? createdAt,
    this.estimatedByAI = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id:            doc.id,
      name:          d['name']          ?? '',
      intensity:     d['intensity']     ?? 'sedang',
      duration:      d['duration']      ?? 0,
      caloriesBurned: d['caloriesBurned'] ?? 0,
      createdAt:     (d['createdAt'] as Timestamp).toDate(),
      estimatedByAI: d['estimatedByAI'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':           name,
    'intensity':      intensity,
    'duration':       duration,
    'caloriesBurned': caloriesBurned,
    'createdAt':      Timestamp.fromDate(createdAt),
    'estimatedByAI':  estimatedByAI,
  };
}