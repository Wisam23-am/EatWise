import 'dart:convert';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:http/http.dart' as http;
import '../models/food_product.dart';

class CachedItem {
  final FoodProduct product;
  final DateTime timestamp;

  CachedItem(this.product, this.timestamp);
}

class OpenFoodFactsService {
  static const String _userAgent = 'EatWise/1.0.0 (contact@eatwise.app)';
  // Gunakan URL API yang stabil
  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v2/product/';

  static final Map<String, CachedItem> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 10);

  Future<FoodProduct?> getProductByBarcode(String barcode) async {
    // 1. Cek Cache
    if (_cache.containsKey(barcode)) {
      final cachedItem = _cache[barcode]!;
      final difference = DateTime.now().difference(cachedItem.timestamp);
      if (difference < _cacheDuration) {
        debugPrint('📦 Cache Hit: $barcode');
        return cachedItem.product;
      } else {
        _cache.remove(barcode);
      }
    }

    try {
      final uri = Uri.parse('$_baseUrl$barcode.json');
      debugPrint('🌐 Fetching: $uri');

      final response = await http
          .get(
            uri,
            headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // API v2 mengembalikan status 1 jika ditemukan
        if (data['status'] == 1 || (data['product'] != null)) {
          // --- PERBAIKAN FATAL DISINI ---
          // Sebelumnya: FoodProduct.fromJson(data['product']); -> SALAH (membuat data null)
          // Seharusnya: FoodProduct.fromJson(data); -> BENAR (Model mengharapkan root JSON)
          final product = FoodProduct.fromJson(data);

          _cache[barcode] = CachedItem(product, DateTime.now());
          return product;
        } else {
          debugPrint(
            '❌ Status produk tidak ditemukan (status: ${data['status']})',
          );
          return null;
        }
      } else {
        debugPrint('⚠️ HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Exception: $e');
      throw Exception('Gagal memuat data produk: $e');
    }
  }
}
