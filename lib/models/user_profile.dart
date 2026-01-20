class UserProfile {
  final int age;
  final double weight; // dalam kg
  final double height; // dalam cm
  final String gender; // 'Laki-laki' atau 'Perempuan'
  final List<String>
  medicalConditions; // Diabetes, Hipertensi, Kolesterol Tinggi, dll
  final List<String> allergies; // Alergi makanan
  final String activityLevel; // Rendah, Sedang, Tinggi
  final String goal; // Diet, Maintain, Bulking

  UserProfile({
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.medicalConditions,
    required this.allergies,
    required this.activityLevel,
    required this.goal,
  });

  // Hitung BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Kategori BMI
  String get bmiCategory {
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Gemuk';
    return 'Obesitas';
  }

  // Kalori harian yang direkomendasikan (Harris-Benedict)
  double get dailyCalorieNeeds {
    double bmr;
    if (gender == 'Laki-laki') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    double multiplier = activityLevel == 'Tinggi'
        ? 1.725
        : activityLevel == 'Sedang'
        ? 1.55
        : 1.375;

    return bmr * multiplier;
  }

  Map<String, dynamic> toJson() => {
    'age': age,
    'weight': weight,
    'height': height,
    'gender': gender,
    'medicalConditions': medicalConditions,
    'allergies': allergies,
    'activityLevel': activityLevel,
    'goal': goal,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    age: json['age'],
    weight: json['weight'],
    height: json['height'],
    gender: json['gender'],
    medicalConditions: List<String>.from(json['medicalConditions']),
    allergies: List<String>.from(json['allergies']),
    activityLevel: json['activityLevel'],
    goal: json['goal'],
  );
}
