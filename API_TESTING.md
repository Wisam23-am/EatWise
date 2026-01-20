# Dokumentasi API & Testing

## Open Food Facts API

Aplikasi ini menggunakan Open Food Facts API v2 untuk mendapatkan informasi produk makanan.

### Base URL
```
https://world.openfoodfacts.org/api/v2
```

### Endpoints yang Digunakan

#### 1. Get Product by Barcode
```
GET /product/{barcode}
```

**Contoh Request:**
```
https://world.openfoodfacts.org/api/v2/product/8998866200486
```

**Response (Success):**
```json
{
  "status": 1,
  "code": "8998866200486",
  "product": {
    "product_name": "Indomie Goreng",
    "brands": "Indomie",
    "image_url": "https://...",
    "nutriments": {
      "energy-kcal_100g": 448,
      "proteins_100g": 8.9,
      "carbohydrates_100g": 63.4,
      "sugars_100g": 3.2,
      "fat_100g": 17.8,
      "saturated-fat_100g": 8.9,
      "salt_100g": 2.87,
      "sodium_100g": 1.15
    },
    "allergens_tags": ["en:gluten"],
    "nutriscore_grade": "d",
    "ingredients_text": "...",
    "additives_tags": ["en:e621"]
  }
}
```

#### 2. Search Products
```
GET /search?search_terms={query}&page_size={size}
```

**Contoh:**
```
https://world.openfoodfacts.org/api/v2/search?search_terms=coca%20cola&page_size=10
```

## Testing Barcode

### Barcode Produk Indonesia
- **Indomie Goreng**: `8998866200486`
- **Indomie Soto**: `8998866201827`
- **Aqua**: `8991002010017`
- **Teh Botol Sosro**: `8992753100114`

### Barcode Produk International
- **Nutella**: `3017620422003`
- **Coca Cola**: `5449000000996`
- **KitKat**: `5000159484725`
- **Oreo**: `7622210449283`

### Testing tanpa Device Camera

Jika tidak memiliki device dengan kamera, gunakan **Manual Barcode Screen**:

1. Jalankan aplikasi
2. Input data user
3. Di scanner screen, tap icon keyboard di kanan atas
4. Masukkan barcode manual dari list di atas
5. Tap "Cari Produk"

## Contoh Skenario Testing

### Skenario 1: User dengan Diabetes
**User Profile:**
- Umur: 45 tahun
- Berat: 75 kg
- Tinggi: 170 cm
- Riwayat Penyakit: Diabetes
- Goal: Diet

**Test dengan:**
- Coca Cola (5449000000996) - Akan muncul warning tinggi gula
- Aqua (8991002010017) - Aman dikonsumsi

### Skenario 2: User dengan Hipertensi
**User Profile:**
- Umur: 50 tahun
- Berat: 80 kg
- Tinggi: 165 cm
- Riwayat Penyakit: Hipertensi
- Goal: Maintain

**Test dengan:**
- Indomie (8998866200486) - Akan muncul warning tinggi natrium

### Skenario 3: User dengan Alergi
**User Profile:**
- Umur: 25 tahun
- Berat: 60 kg
- Tinggi: 160 cm
- Alergi: Susu, Kacang
- Goal: Bulking

**Test dengan:**
- Nutella (3017620422003) - Akan muncul warning alergen (susu & kacang)

## Logic Analisis

### 1. Pengecekan Alergi
- Severity: **HIGH** (Berbahaya)
- Cek di `allergens_tags` dan `ingredients_text`
- Jika match dengan alergi user → Tidak disarankan

### 2. Pengecekan Kondisi Medis

#### Diabetes
- Gula > 15g/100g → HIGH warning
- Gula > 5g/100g → MEDIUM warning

#### Hipertensi
- Sodium > 0.5g/100g → HIGH warning
- Garam > 1.5g/100g → MEDIUM warning

#### Kolesterol Tinggi
- Lemak Jenuh > 5g/100g → HIGH warning

#### Obesitas
- Kalori > 400 kcal/100g → MEDIUM warning

### 3. Pengecekan Goal

#### Diet
- Kalori > 300 → LOW warning
- Serat > 5g → Recommendation

#### Bulking
- Protein > 10g → Recommendation
- Kalori < 200 → Recommendation (tambah porsi)

#### Maintain
- Kalori > 500 → LOW warning

### 4. Nutriscore Grade
- A: Sangat Baik
- B: Baik
- C: Cukup
- D: LOW warning
- E: MEDIUM warning

### 5. Additives Berbahaya
Common harmful additives yang dicek:
- E102, E104, E110, E122, E124, E129 (Pewarna)
- E211 (Pengawet)
- E220 (Sulfit)
- E621 (MSG) - MEDIUM warning

## Scoring System

**Base Score: 100**

Pengurangan per warning:
- HIGH warning: -30 poin
- MEDIUM warning: -15 poin
- LOW warning: -5 poin

**Kategori Skor:**
- 80-100: Sangat Baik
- 60-79: Baik
- 40-59: Cukup
- 20-39: Kurang Baik
- 0-19: Tidak Disarankan

**Status Aman:**
- Aman: Tidak ada HIGH warning
- Tidak Aman: Ada HIGH warning (alergi atau kondisi kesehatan serius)

## Tips Development

### 1. Testing API tanpa Emulator
Gunakan browser atau Postman untuk test API:
```
https://world.openfoodfacts.org/api/v2/product/8998866200486
```

### 2. Debug Print
Uncomment print statements di:
- `food_api_service.dart` untuk cek API response
- `food_analyzer.dart` untuk cek logic analisis

### 3. Mock Data
Jika offline, bisa create mock `FoodProduct` untuk testing UI:
```dart
final mockProduct = FoodProduct(
  barcode: '123456789',
  productName: 'Test Product',
  // ... fill other fields
);
```

### 4. Shared Preferences Testing
Data user tersimpan dengan key: `user_profile`

Clear data untuk testing fresh install:
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

## Troubleshooting

### Error: Camera Permission Denied
**Android:** Check AndroidManifest.xml
**iOS:** Check Info.plist NSCameraUsageDescription

### Error: Product Not Found
- Pastikan barcode valid (cek di Open Food Facts website)
- Cek koneksi internet
- Beberapa produk lokal mungkin belum ada di database

### Error: Null Nutriments
- Tidak semua produk memiliki data nutrisi lengkap
- App sudah handle dengan null check (?)

### API Rate Limiting
Open Food Facts API tidak memiliki rate limit ketat, tapi:
- Jangan spam requests
- Cache hasil jika perlu

---

**Happy Testing! 🚀**
