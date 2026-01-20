import '../models/user_profile.dart';
import '../models/food_product.dart';

class FoodAnalyzer {
  /// Menganalisis apakah makanan cocok untuk user
  static AnalysisResult analyzeFoodSuitability(
    UserProfile user,
    FoodProduct food,
  ) {
    List<Warning> warnings = [];
    List<String> recommendations = [];
    bool isSafe = true;

    // 1. Cek Alergi
    _checkAllergies(user, food, warnings);

    // 2. Cek Kondisi Kesehatan
    _checkMedicalConditions(user, food, warnings);

    // 3. Cek Nutrisi berdasarkan Goal
    _checkNutritionGoals(user, food, warnings, recommendations);

    // 4. Cek Kualitas Makanan (Nutriscore)
    _checkFoodQuality(food, warnings, recommendations);

    // 5. Cek Additives berbahaya
    _checkAdditives(food, warnings);

    // Tentukan apakah aman
    isSafe = !warnings.any((w) => w.severity == WarningSeverity.high);

    return AnalysisResult(
      isSafe: isSafe,
      warnings: warnings,
      recommendations: recommendations,
      overallScore: _calculateScore(warnings),
    );
  }

  static void _checkAllergies(
    UserProfile user,
    FoodProduct food,
    List<Warning> warnings,
  ) {
    for (var allergy in user.allergies) {
      for (var allergen in food.allergens) {
        if (allergen.toLowerCase().contains(allergy.toLowerCase()) ||
            allergy.toLowerCase().contains(allergen.toLowerCase())) {
          warnings.add(
            Warning(
              title: 'Peringatan Alergi!',
              message:
                  'Produk ini mengandung $allergen yang mungkin memicu alergi Anda terhadap $allergy',
              severity: WarningSeverity.high,
            ),
          );
        }
      }

      // Cek di ingredients juga
      final ingredientsText = food.ingredients.join(' ').toLowerCase();
      if (ingredientsText.contains(allergy.toLowerCase())) {
        warnings.add(
          Warning(
            title: 'Kemungkinan Mengandung Alergen',
            message: 'Bahan makanan mungkin mengandung $allergy',
            severity: WarningSeverity.high,
          ),
        );
      }
    }
  }

  static void _checkMedicalConditions(
    UserProfile user,
    FoodProduct food,
    List<Warning> warnings,
  ) {
    final nutriments = food.nutriments;
    if (nutriments == null) return;

    for (var condition in user.medicalConditions) {
      switch (condition.toLowerCase()) {
        case 'diabetes':
        case 'diabetes mellitus':
          if ((nutriments.sugars ?? 0) > 15) {
            warnings.add(
              Warning(
                title: 'Tinggi Gula',
                message:
                    'Produk ini mengandung ${nutriments.sugars?.toStringAsFixed(1)}g gula per 100g. Tidak disarankan untuk penderita diabetes.',
                severity: WarningSeverity.high,
              ),
            );
          } else if ((nutriments.sugars ?? 0) > 5) {
            warnings.add(
              Warning(
                title: 'Perhatian Kadar Gula',
                message:
                    'Produk ini mengandung ${nutriments.sugars?.toStringAsFixed(1)}g gula per 100g. Konsumsi dengan hati-hati.',
                severity: WarningSeverity.medium,
              ),
            );
          }
          break;

        case 'hipertensi':
        case 'darah tinggi':
          if ((nutriments.sodium ?? 0) > 0.5) {
            warnings.add(
              Warning(
                title: 'Tinggi Natrium',
                message:
                    'Produk ini mengandung ${nutriments.sodium?.toStringAsFixed(2)}g natrium per 100g. Tidak disarankan untuk penderita hipertensi.',
                severity: WarningSeverity.high,
              ),
            );
          } else if ((nutriments.salt ?? 0) > 1.5) {
            warnings.add(
              Warning(
                title: 'Perhatian Kadar Garam',
                message:
                    'Produk ini mengandung ${nutriments.salt?.toStringAsFixed(1)}g garam per 100g.',
                severity: WarningSeverity.medium,
              ),
            );
          }
          break;

        case 'kolesterol tinggi':
        case 'kolesterol':
          if ((nutriments.saturatedFat ?? 0) > 5) {
            warnings.add(
              Warning(
                title: 'Tinggi Lemak Jenuh',
                message:
                    'Produk ini mengandung ${nutriments.saturatedFat?.toStringAsFixed(1)}g lemak jenuh per 100g. Dapat meningkatkan kolesterol.',
                severity: WarningSeverity.high,
              ),
            );
          }
          break;

        case 'obesitas':
          if ((nutriments.energyKcal ?? 0) > 400) {
            warnings.add(
              Warning(
                title: 'Tinggi Kalori',
                message:
                    'Produk ini mengandung ${nutriments.energyKcal?.toStringAsFixed(0)} kalori per 100g. Batasi konsumsi.',
                severity: WarningSeverity.medium,
              ),
            );
          }
          break;
      }
    }
  }

  static void _checkNutritionGoals(
    UserProfile user,
    FoodProduct food,
    List<Warning> warnings,
    List<String> recommendations,
  ) {
    final nutriments = food.nutriments;
    if (nutriments == null) return;

    switch (user.goal.toLowerCase()) {
      case 'diet':
        if ((nutriments.energyKcal ?? 0) > 300) {
          warnings.add(
            Warning(
              title: 'Kalori Tinggi untuk Diet',
              message:
                  'Produk ini cukup tinggi kalori (${nutriments.energyKcal?.toStringAsFixed(0)} kcal/100g).',
              severity: WarningSeverity.low,
            ),
          );
        }
        if ((nutriments.fiber ?? 0) > 5) {
          recommendations.add(
            'Bagus! Tinggi serat (${nutriments.fiber?.toStringAsFixed(1)}g) membantu program diet Anda.',
          );
        }
        break;

      case 'bulking':
        if ((nutriments.proteins ?? 0) > 10) {
          recommendations.add(
            'Bagus! Tinggi protein (${nutriments.proteins?.toStringAsFixed(1)}g) mendukung program bulking Anda.',
          );
        }
        if ((nutriments.energyKcal ?? 0) < 200) {
          recommendations.add(
            'Kalori rendah untuk bulking. Pertimbangkan porsi lebih besar.',
          );
        }
        break;

      case 'maintain':
        if ((nutriments.energyKcal ?? 0) > 500) {
          warnings.add(
            Warning(
              title: 'Kalori Cukup Tinggi',
              message: 'Sesuaikan porsi untuk menjaga kalori harian Anda.',
              severity: WarningSeverity.low,
            ),
          );
        }
        break;
    }
  }

  static void _checkFoodQuality(
    FoodProduct food,
    List<Warning> warnings,
    List<String> recommendations,
  ) {
    if (food.nutriscoreGrade != null) {
      switch (food.nutriscoreGrade!.toLowerCase()) {
        case 'a':
          recommendations.add('Nutriscore A - Kualitas nutrisi sangat baik!');
          break;
        case 'b':
          recommendations.add('Nutriscore B - Kualitas nutrisi baik.');
          break;
        case 'c':
          recommendations.add('Nutriscore C - Kualitas nutrisi cukup.');
          break;
        case 'd':
          warnings.add(
            Warning(
              title: 'Nutriscore D',
              message: 'Kualitas nutrisi kurang baik. Konsumsi sesekali.',
              severity: WarningSeverity.low,
            ),
          );
          break;
        case 'e':
          warnings.add(
            Warning(
              title: 'Nutriscore E',
              message: 'Kualitas nutrisi buruk. Hindari konsumsi rutin.',
              severity: WarningSeverity.medium,
            ),
          );
          break;
      }
    }
  }

  static void _checkAdditives(FoodProduct food, List<Warning> warnings) {
    // Daftar additives berbahaya yang umum
    final dangerousAdditives = [
      'e102',
      'e104',
      'e110',
      'e122',
      'e124',
      'e129', // Pewarna berbahaya
      'e211',
      'e220',
      'e621', // MSG
    ];

    for (var additive in food.additives) {
      final additiveCode = additive.toLowerCase().replaceAll('en:', '');
      if (dangerousAdditives.contains(additiveCode)) {
        warnings.add(
          Warning(
            title: 'Mengandung Bahan Tambahan Berisiko',
            message:
                'Produk mengandung $additiveCode yang sebaiknya dihindari.',
            severity: WarningSeverity.medium,
          ),
        );
      }
    }
  }

  static double _calculateScore(List<Warning> warnings) {
    double score = 100.0;

    for (var warning in warnings) {
      switch (warning.severity) {
        case WarningSeverity.high:
          score -= 30;
          break;
        case WarningSeverity.medium:
          score -= 15;
          break;
        case WarningSeverity.low:
          score -= 5;
          break;
      }
    }

    return score.clamp(0, 100);
  }
}

class AnalysisResult {
  final bool isSafe;
  final List<Warning> warnings;
  final List<String> recommendations;
  final double overallScore;

  AnalysisResult({
    required this.isSafe,
    required this.warnings,
    required this.recommendations,
    required this.overallScore,
  });

  String get scoreCategory {
    if (overallScore >= 80) return 'Sangat Baik';
    if (overallScore >= 60) return 'Baik';
    if (overallScore >= 40) return 'Cukup';
    if (overallScore >= 20) return 'Kurang Baik';
    return 'Tidak Disarankan';
  }
}

class Warning {
  final String title;
  final String message;
  final WarningSeverity severity;

  Warning({required this.title, required this.message, required this.severity});
}

enum WarningSeverity {
  high, // Berbahaya, tidak disarankan
  medium, // Perlu perhatian
  low, // Informasi
}
