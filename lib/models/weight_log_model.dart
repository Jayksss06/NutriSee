import 'package:cloud_firestore/cloud_firestore.dart';

class WeightLogModel {
  final String? id;
  final double weight;
  final DateTime loggedAt;

  WeightLogModel({
    this.id,
    required this.weight,
    DateTime? loggedAt,
  }) : loggedAt = loggedAt ?? DateTime.now();

  factory WeightLogModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WeightLogModel(
      id:       doc.id,
      weight:   (d['weight'] ?? 0).toDouble(),
      loggedAt: (d['loggedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'weight':   weight,
    'loggedAt': Timestamp.fromDate(loggedAt),
  };
}