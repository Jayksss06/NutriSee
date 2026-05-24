import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  String name;
  String email;
  String gender;
  DateTime? birthDate;
  double weight;
  double height;
  double targetWeight;
  String? profileImage;

  UserModel({
    required this.uid,
    this.name = '',
    this.email = '',
    this.gender = 'Laki-laki',
    this.birthDate,
    this.weight = 0,
    this.height = 0,
    this.targetWeight = 0,
    this.profileImage,
  });

  // ── Computed ──────────────────────────────────────────
  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int a = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) a--;
    return a;
  }

  double get bmi {
    if (height == 0) return 0;
    final h = height / 100;
    return weight / (h * h);
  }

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Kekurangan Berat Badan';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Kelebihan Berat Badan';
    return 'Obesitas';
  }

  int get targetCalories {
    double bmr = gender == 'Laki-laki'
        ? 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        : 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    return (bmr * 1.2).round();
  }

  int get targetCarbs   => ((targetCalories * 0.50) / 4).round();
  int get targetProtein => ((targetCalories * 0.25) / 4).round();
  int get targetFat     => ((targetCalories * 0.25) / 9).round();

  // ── Firestore ─────────────────────────────────────────
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid:           doc.id,
      name:          d['name']          ?? '',
      email:         d['email']         ?? '',
      gender:        d['gender']        ?? 'Laki-laki',
      birthDate:     (d['birthDate'] as Timestamp?)?.toDate(),
      weight:        (d['weight']       ?? 0).toDouble(),
      height:        (d['height']       ?? 0).toDouble(),
      targetWeight:  (d['targetWeight'] ?? 0).toDouble(),
      profileImage:  d['profileImage'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':         name,
    'email':        email,
    'gender':       gender,
    'birthDate':    birthDate != null ? Timestamp.fromDate(birthDate!) : null,
    'weight':       weight,
    'height':       height,
    'targetWeight': targetWeight,
    'profileImage': profileImage,
    'updatedAt':    FieldValue.serverTimestamp(),
  };
}