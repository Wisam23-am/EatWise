/// Constants used throughout the app
class AppConstants {
  // App Info
  static const String appName = 'FoodFect';
  static const String appTagline = 'Scan & Cek Makananmu';

  // Storage Keys
  static const String userProfileKey = 'user_profile';

  // API
  static const String apiBaseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const int apiTimeout = 30; // seconds

  // Validation Limits
  static const int minAge = 1;
  static const int maxAge = 120;
  static const double minWeight = 20.0;
  static const double maxWeight = 300.0;
  static const double minHeight = 50.0;
  static const double maxHeight = 250.0;

  // BMI Categories
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 25.0;
  static const double bmiOverweight = 30.0;

  // Activity Level Multipliers (for calorie calculation)
  static const double activityLow = 1.375;
  static const double activityMedium = 1.55;
  static const double activityHigh = 1.725;

  // Nutrition Thresholds (per 100g)
  static const double highSugar = 15.0; // g
  static const double mediumSugar = 5.0; // g
  static const double highSodium = 0.5; // g
  static const double highSalt = 1.5; // g
  static const double highSaturatedFat = 5.0; // g
  static const double highCalories = 400.0; // kcal
  static const double highFiber = 5.0; // g
  static const double highProtein = 10.0; // g

  // Diet Goals
  static const double dietCalorieThreshold = 300.0;
  static const double bulkingCalorieThreshold = 200.0;
  static const double maintainCalorieThreshold = 500.0;

  // Scoring
  static const double baseScore = 100.0;
  static const double highWarningPenalty = 30.0;
  static const double mediumWarningPenalty = 15.0;
  static const double lowWarningPenalty = 5.0;

  // Score Categories
  static const double excellentScoreMin = 80.0;
  static const double goodScoreMin = 60.0;
  static const double fairScoreMin = 40.0;
  static const double poorScoreMin = 20.0;

  // Dangerous Additives (E-numbers)
  static const List<String> dangerousAdditives = [
    'e102', // Tartrazine (Yellow)
    'e104', // Quinoline Yellow
    'e110', // Sunset Yellow
    'e122', // Carmoisine
    'e124', // Ponceau 4R
    'e129', // Allura Red
    'e211', // Sodium Benzoate
    'e220', // Sulphur Dioxide
    'e621', // MSG
  ];

  // Sample Barcodes for Testing
  static const Map<String, String> sampleBarcodes = {
    'Nutella': '3017620422003',
    'Coca Cola': '5449000000996',
    'Indomie': '8998866200486',
    'KitKat': '5000159484725',
    'Oreo': '7622210449283',
  };

  // Medical Conditions
  static const List<String> medicalConditions = [
    'Diabetes',
    'Hipertensi',
    'Kolesterol Tinggi',
    'Obesitas',
    'Asam Urat',
    'Maag',
  ];

  // Common Allergies
  static const List<String> commonAllergies = [
    'Kacang',
    'Susu',
    'Telur',
    'Ikan',
    'Udang',
    'Gandum',
    'Kedelai',
  ];

  // Gender Options
  static const List<String> genderOptions = ['Laki-laki', 'Perempuan'];

  // Activity Levels
  static const List<String> activityLevels = ['Rendah', 'Sedang', 'Tinggi'];

  // Goals
  static const List<String> goals = ['Diet', 'Maintain', 'Bulking'];
}
