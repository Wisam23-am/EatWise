import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_product.dart';

class OpenFoodFactsService {
  static const String baseUrl = 'https://world.openfoodfacts.org/api/v2';

  /// Mendapatkan informasi produk berdasarkan barcode
  Future<FoodProduct?> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$baseUrl/product/$barcode');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Cek apakah produk ditemukan
        if (data['status'] == 1) {
          return FoodProduct.fromJson(data);
        } else {
          return null; // Produk tidak ditemukan
        }
      } else {
        throw Exception('Gagal mengambil data produk');
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  /// Mencari produk berdasarkan nama
  Future<List<FoodProduct>> searchProducts(String query) async {
    try {
      final url = Uri.parse('$baseUrl/search?search_terms=$query&page_size=10');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List;

        return products.map((p) {
          return FoodProduct.fromJson({'product': p, 'code': p['code']});
        }).toList();
      } else {
        throw Exception('Gagal mencari produk');
      }
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}
