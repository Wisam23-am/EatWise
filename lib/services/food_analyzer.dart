import '../models/user_profile.dart';
import '../models/food_product.dart';
import '../utils/constants.dart';

// Enum untuk Traffic Light System
enum TrafficLight {
  green, // Aman / Direkomendasikan
  yellow, // Hati-hati / Konsumsi Terbatas
  red, // Bahaya / Tidak Disarankan
}

class FoodAnalyzer {
  /// Menganalisis apakah makanan cocok untuk user dengan logika Smart Analysis
  static AnalysisResult analyzeFoodSuitability(
    UserProfile user,
    FoodProduct food,
  ) {
    List<Warning> warnings = [];
    List<String> recommendations = [];

    // 1. Cek Alergi (Prioritas Tertinggi)
    _checkAllergies(user, food, warnings);

    // 2. Cek Kondisi Kesehatan & Nutrisi
    _checkMedicalConditions(user, food, warnings);

    // 3. Cek Nutrisi berdasarkan Goal
    _checkNutritionGoals(user, food, warnings, recommendations);

    // 4. Cek Kualitas Makanan (Nutriscore)
    _checkFoodQuality(food, warnings, recommendations);

    // 5. Cek Additives berbahaya (Dengan deteksi nama)
    _checkAdditives(food, warnings);

    // --- LOGIKA TRAFFIC LIGHT ---
    TrafficLight trafficLight;

    // Jika ada warning level HIGH (Merah), status langsung Merah
    if (warnings.any((w) => w.severity == WarningSeverity.high)) {
      trafficLight = TrafficLight.red;
    }
    // Jika ada warning level MEDIUM, atau Skor rendah, status Kuning
    else if (warnings.any((w) => w.severity == WarningSeverity.medium)) {
      trafficLight = TrafficLight.yellow;
    }
    // Sisanya Hijau
    else {
      trafficLight = TrafficLight.green;
    }

    return AnalysisResult(
      trafficLight: trafficLight,
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
    // Normalisasi input user
    final userAllergies = user.allergies.map((a) => a.toLowerCase()).toList();

    // Cek Allergens Tags dari API
    for (var allergenTag in food.allergens) {
      final allergen = allergenTag.toLowerCase();
      for (var userAllergy in userAllergies) {
        if (allergen.contains(userAllergy) || userAllergy.contains(allergen)) {
          warnings.add(
            Warning(
              title: 'BAHAYA: Mengandung $userAllergy!',
              message:
                  'Produk ini terdeteksi mengandung $allergenTag. Sangat berbahaya bagi alergi Anda.',
              severity: WarningSeverity.high,
            ),
          );
          return; // Langsung return agar tidak duplikat warning
        }
      }
    }

    // Cek Ingredients Text (Backup jika tags kosong)
    final ingredientsText = food.ingredients.join(' ').toLowerCase();
    for (var userAllergy in userAllergies) {
      if (ingredientsText.contains(userAllergy)) {
        warnings.add(
          Warning(
            title: 'Peringatan Komposisi',
            message: 'Ditemukan bahan "$userAllergy" dalam komposisi produk.',
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
    final n = food.nutriments;
    if (n == null) return;

    for (var condition in user.medicalConditions) {
      switch (condition.toLowerCase()) {
        case 'diabetes':
          if ((n.sugars ?? 0) > AppConstants.highSugar) {
            warnings.add(
              Warning(
                title: 'Bahaya Diabetes',
                message:
                    'Gula sangat tinggi (${n.sugars}g). Melebihi batas aman 15g.',
                severity: WarningSeverity.high,
              ),
            );
          } else if ((n.sugars ?? 0) > AppConstants.mediumSugar) {
            warnings.add(
              Warning(
                title: 'Perhatian Diabetes',
                message: 'Kandungan gula (${n.sugars}g) perlu dibatasi.',
                severity: WarningSeverity.medium,
              ),
            );
          }
          break;

        case 'hipertensi':
          // Cek Sodium (Natrium) dan Salt (Garam)
          if ((n.sodium ?? 0) > AppConstants.highSodium ||
              (n.salt ?? 0) > AppConstants.highSalt) {
            warnings.add(
              Warning(
                title: 'Bahaya Hipertensi',
                message:
                    'Garam/Natrium tinggi. Dapat memicu tekanan darah naik.',
                severity: WarningSeverity.high,
              ),
            );
          }
          break;

        case 'kolesterol tinggi':
        case 'kolesterol':
          if ((n.saturatedFat ?? 0) > AppConstants.highSaturatedFat) {
            warnings.add(
              Warning(
                title: 'Bahaya Kolesterol',
                message:
                    'Lemak jenuh tinggi (${n.saturatedFat}g). Buruk untuk jantung.',
                severity: WarningSeverity.high,
              ),
            );
          }
          break;

        case 'obesitas':
          if ((n.energyKcal ?? 0) > AppConstants.highCalories) {
            warnings.add(
              Warning(
                title: 'Sangat Tinggi Kalori',
                message:
                    '${n.energyKcal?.toStringAsFixed(0)} kkal per 100g. Sangat padat energi.',
                severity: WarningSeverity.high,
              ),
            );
          } else if ((n.sugars ?? 0) > 10 || (n.fat ?? 0) > 15) {
            warnings.add(
              Warning(
                title: 'Potensi Penambahan Berat',
                message:
                    'Kombinasi gula/lemak tinggi dapat menghambat penurunan berat badan.',
                severity: WarningSeverity.medium,
              ),
            );
          }
          break;

        case 'maag':
        case 'asam lambung':
          // Deteksi kasar dari kategori atau bahan (jika ada data pedas/asam)
          // Ini placeholder logika karena data spesifik pH jarang ada di API standar
          if ((n.fat ?? 0) > 20) {
            warnings.add(
              Warning(
                title: 'Lemak Tinggi',
                message:
                    'Makanan berlemak tinggi dapat memicu asam lambung naik.',
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
    final n = food.nutriments;
    if (n == null) return;

    // Logika Goal
    if (user.goal == 'Diet') {
      if ((n.fiber ?? 0) >= AppConstants.highFiber) {
        recommendations.add(
          '✨ Super Food untuk Diet: Tinggi serat (${n.fiber}g) membuat kenyang lebih lama.',
        );
      }
      if ((n.proteins ?? 0) >= AppConstants.highProtein) {
        recommendations.add(
          '✅ Protein cukup tinggi membantu metabolisme saat diet.',
        );
      }
    } else if (user.goal == 'Bulking') {
      if ((n.proteins ?? 0) >= AppConstants.highProtein) {
        recommendations.add('💪 Excellent: Sumber protein tinggi untuk otot.');
      }
      if ((n.energyKcal ?? 0) > 300) {
        recommendations.add('🔥 Bagus untuk surplus kalori harian.');
      }
    }
  }

  static void _checkFoodQuality(
    FoodProduct food,
    List<Warning> warnings,
    List<String> recommendations,
  ) {
    if (food.nutriscoreGrade != null) {
      final grade = food.nutriscoreGrade!.toLowerCase();
      if (grade == 'a') {
        recommendations.add('🏆 Nutriscore A: Kualitas nutrisi terbaik.');
      } else if (grade == 'd' || grade == 'e') {
        warnings.add(
          Warning(
            title: 'Kualitas Nutrisi Rendah (Grade $grade)',
            message:
                'Produk ini minim gizi penting dan tinggi gula/garam/lemak.',
            severity:
                WarningSeverity.medium, // Medium karena bukan racun, tapi buruk
          ),
        );
      }
    }
  }

  static void _checkAdditives(FoodProduct food, List<Warning> warnings) {
    // Menggunakan Map dari Constants
    final dangerousMap = AppConstants.dangerousAdditivesDetails;

    for (var additiveTag in food.additives) {
      // Format API biasanya "en:e102". Kita ambil kodenya saja "e102"
      final code = additiveTag.toLowerCase().replaceAll('en:', '').trim();

      if (dangerousMap.containsKey(code)) {
        final description = dangerousMap[code];
        warnings.add(
          Warning(
            title: 'Bahan Tambahan Berisiko ($code)',
            message: 'Mengandung $description.',
            severity: WarningSeverity.medium, // Warning sedang
          ),
        );
      }
    }
  }

  static double _calculateScore(List<Warning> warnings) {
    double score = 100.0;
    for (var w in warnings) {
      switch (w.severity) {
        case WarningSeverity.high:
          score -= 40;
          break; // Hukuman lebih berat
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

// Model Hasil Analisis yang diperbarui
class AnalysisResult {
  final TrafficLight trafficLight; // Indikator Utama
  final List<Warning> warnings;
  final List<String> recommendations;
  final double overallScore;

  AnalysisResult({
    required this.trafficLight,
    required this.warnings,
    required this.recommendations,
    required this.overallScore,
  });

  bool get isSafe => trafficLight != TrafficLight.red;

  String get scoreCategory {
    if (overallScore >= 80) return 'Sangat Sehat';
    if (overallScore >= 60) return 'Cukup Sehat';
    if (overallScore >= 40) return 'Kurang Sehat';
    return 'Tidak Sehat';
  }
}

class Warning {
  final String title;
  final String message;
  final WarningSeverity severity;

  Warning({required this.title, required this.message, required this.severity});
}

enum WarningSeverity {
  high, // Merah (Bahaya)
  medium, // Kuning (Peringatan)
  low, // Info
}
