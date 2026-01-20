import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../models/food_product.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiFoodRecognitionService {
  static final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  late final GenerativeModel _model;

  GeminiFoodRecognitionService() {
    _model = GenerativeModel(model: 'gemini-3-flash-preview', apiKey: apiKey);
  }

  Future<FoodProduct?> recognizeFood(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      final prompt = '''
Analisis gambar makanan ini. Berikan hasil dalam JSON format:
{
  "product_name": "nama makanan lengkap",
  "brands": "brand jika terlihat",
  "portion": "estimasi porsi (gram)",
  "confidence": 0.95,
  "nutriments": {
    "energy-kcal_100g": 200,
    "proteins_100g": 5.0,
    "carbohydrates_100g": 30.0,
    "sugars_100g": 10.0,
    "fat_100g": 8.0,
    "saturated-fat_100g": 3.0,
    "fiber_100g": 2.0,
    "salt_100g": 0.5,
    "sodium_100g": 0.2
  },
  "ingredients_text": "bahan-bahan yang terlihat",
  "allergens_tags": ["en:milk", "en:nuts"],
  "nutriscore_grade": "b",
  "categories": "kategori makanan"
}

Jika bukan makanan, return: {"error": "Bukan gambar makanan"}
PENTING: Estimasi nutrisi per 100g untuk konsistensi.
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);
      final text = response.text;

      if (text == null) return null;

      // Extract JSON
      String jsonText = text;
      if (text.contains('```json')) {
        jsonText = text.split('```json')[1].split('```')[0].trim();
      } else if (text.contains('```')) {
        jsonText = text.split('```')[1].split('```')[0].trim();
      }

      final jsonData = json.decode(jsonText);

      if (jsonData.containsKey('error')) {
        throw Exception(jsonData['error']);
      }

      // Convert ke FoodProduct format
      final foodProductJson = {
        'code': 'photo_${DateTime.now().millisecondsSinceEpoch}',
        'product': jsonData,
      };
      print('Gemini response: $text');

      return FoodProduct.fromJson(foodProductJson);
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
