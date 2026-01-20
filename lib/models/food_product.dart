class FoodProduct {
  final String barcode;
  final String? productName;
  final String? brands;
  final String? imageUrl;
  final Nutriments? nutriments;
  final List<String> ingredients;
  final List<String> allergens;
  final String? nutriscoreGrade;
  final List<String> additives;
  final String? categories;

  FoodProduct({
    required this.barcode,
    this.productName,
    this.brands,
    this.imageUrl,
    this.nutriments,
    required this.ingredients,
    required this.allergens,
    this.nutriscoreGrade,
    required this.additives,
    this.categories,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};

    return FoodProduct(
      barcode: json['code'] ?? '',
      productName: product['product_name'] ?? product['product_name_id'],
      brands: product['brands'],
      imageUrl: product['image_url'],
      nutriments: product['nutriments'] != null
          ? Nutriments.fromJson(product['nutriments'])
          : null,
      ingredients: _parseList(product['ingredients_text']),
      allergens: _parseAllergens(product['allergens_tags']),
      nutriscoreGrade: product['nutriscore_grade'],
      additives: _parseList(product['additives_tags']),
      categories: product['categories'],
    );
  }

  static List<String> _parseList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    if (data is String) {
      return [data];
    }
    return [];
  }

  static List<String> _parseAllergens(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) {
        String allergen = e.toString().replaceAll('en:', '');
        return allergen;
      }).toList();
    }
    return [];
  }
}

class Nutriments {
  final double? energyKcal;
  final double? fat;
  final double? saturatedFat;
  final double? carbohydrates;
  final double? sugars;
  final double? fiber;
  final double? proteins;
  final double? salt;
  final double? sodium;

  Nutriments({
    this.energyKcal,
    this.fat,
    this.saturatedFat,
    this.carbohydrates,
    this.sugars,
    this.fiber,
    this.proteins,
    this.salt,
    this.sodium,
  });

  factory Nutriments.fromJson(Map<String, dynamic> json) {
    return Nutriments(
      energyKcal: _parseDouble(json['energy-kcal_100g']),
      fat: _parseDouble(json['fat_100g']),
      saturatedFat: _parseDouble(json['saturated-fat_100g']),
      carbohydrates: _parseDouble(json['carbohydrates_100g']),
      sugars: _parseDouble(json['sugars_100g']),
      fiber: _parseDouble(json['fiber_100g']),
      proteins: _parseDouble(json['proteins_100g']),
      salt: _parseDouble(json['salt_100g']),
      sodium: _parseDouble(json['sodium_100g']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
