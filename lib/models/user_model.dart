class UserModel {
  String name;
  String email;
  String password;
  String gender;
  DateTime? birthDate;
  double weight; // kg
  double height; // cm
  double targetWeight; // kg

  UserModel({
    this.name = '',
    this.email = '',
    this.password = '',
    this.gender = 'Laki-laki',
    this.birthDate,
    this.weight = 0,
    this.height = 0,
    this.targetWeight = 0,
  });

  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  double get bmi {
    if (height == 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  String get bmiCategory {
    final bmiVal = bmi;
    if (bmiVal < 18.5) return 'Kekurangan Berat Badan';
    if (bmiVal < 25) return 'Normal';
    if (bmiVal < 30) return 'Kelebihan Berat Badan';
    return 'Obesitas';
  }

  int get targetCalories {
    // Harris-Benedict equation
    double bmr;
    if (gender == 'Laki-laki') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
    // Sedentary activity factor
    return (bmr * 1.2).round();
  }

  int get targetCarbs => ((targetCalories * 0.5) / 4).round(); // grams
  int get targetProtein => ((targetCalories * 0.25) / 4).round(); // grams
  int get targetFat => ((targetCalories * 0.25) / 9).round(); // grams
}

class FoodEntry {
  final String name;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final DateTime time;
  final String mealType; // breakfast, lunch, dinner, snack

  FoodEntry({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.time,
    required this.mealType,
  });
}

class WeightEntry {
  final DateTime date;
  final double weight;
  WeightEntry({required this.date, required this.weight});
}
