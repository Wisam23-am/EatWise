# FoodFect - Aplikasi Scan Barcode Makanan 🍔📱

Aplikasi Flutter untuk scan barcode makanan dan minuman yang memberikan analisis kesehatan berdasarkan data pribadi pengguna menggunakan API Open Food Facts.

## ✨ Fitur Utama

- **Scan Barcode**: Pindai barcode produk makanan dan minuman dengan kamera
- **Analisis Kesehatan Personal**: Analisis apakah makanan cocok berdasarkan:
  - Umur, berat badan, tinggi badan
  - Riwayat penyakit (Diabetes, Hipertensi, Kolesterol, dll)
  - Alergi makanan
  - Tujuan kesehatan (Diet, Maintain, Bulking)
- **Informasi Nutrisi Lengkap**: Kalori, protein, karbohidrat, lemak, gula, garam, dll
- **Rekomendasi Cerdas**: Dapatkan peringatan dan rekomendasi berdasarkan profil kesehatan
- **Tanpa Akun**: Tidak perlu registrasi, cukup input data saat menggunakan

## 🚀 Cara Menggunakan

1. **Buka Aplikasi**: Tap "Mulai Sekarang" di home screen
2. **Input Data Kesehatan**: 
   - Masukkan data dasar (umur, berat, tinggi)
   - Pilih level aktivitas dan tujuan
   - Pilih riwayat penyakit (jika ada)
   - Pilih alergi makanan (jika ada)
3. **Scan Barcode**: Arahkan kamera ke barcode produk
4. **Lihat Hasil**: Dapatkan analisis lengkap apakah makanan aman untuk Anda

## 📋 Persyaratan

- Flutter SDK 3.10.7 atau lebih tinggi
- Dart SDK yang kompatibel
- Android Studio / Xcode (untuk development)
- Device dengan kamera (untuk scan barcode)

## 🔧 Setup & Instalasi

1. Clone repository:
```bash
git clone <repository-url>
cd foodfect
```

2. Install dependencies:
```bash
flutter pub get
```

3. Jalankan aplikasi:
```bash
flutter run
```

## 🏗️ Struktur Aplikasi

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/
│   ├── user_profile.dart     # Model data user dengan BMI & kalori calculator
│   └── food_product.dart     # Model data produk dari API
├── services/
│   ├── food_api_service.dart # Service untuk Open Food Facts API
│   └── food_analyzer.dart    # Logic analisis kesesuaian makanan
└── screens/
    ├── home_screen.dart      # Home screen
    ├── user_data_screen.dart # Input data user
    ├── barcode_scanner_screen.dart  # Scanner barcode
    └── result_screen.dart    # Tampilan hasil analisis
```

## 📦 Dependencies

- **mobile_scanner**: Scanner barcode
- **http**: HTTP client untuk API calls
- **shared_preferences**: Menyimpan data user sementara
- **google_fonts**: Typography yang menarik

## 🔍 Fitur Analisis

### Pengecekan Otomatis:
- ✅ **Alergi**: Deteksi alergen dalam produk
- ✅ **Kondisi Medis**: Analisis berdasarkan diabetes, hipertensi, kolesterol
- ✅ **Tujuan Diet**: Sesuaikan dengan goal (diet/maintain/bulking)
- ✅ **Kualitas Nutrisi**: Nutriscore A-E dari Open Food Facts
- ✅ **Bahan Tambahan**: Deteksi additives berbahaya

### Perhitungan:
- 📊 **BMI Calculator**: Hitung dan kategorikan BMI
- 🔥 **Kebutuhan Kalori**: Harris-Benedict formula
- ⭐ **Skor Kesesuaian**: 0-100 berdasarkan profil kesehatan

## 🌐 API

Aplikasi ini menggunakan [Open Food Facts API](https://world.openfoodfacts.org/) - database produk makanan terbesar di dunia dengan lebih dari 2 juta produk.

## 📱 Platform Support

- ✅ Android (Minimum SDK 21)
- ✅ iOS (Minimum iOS 12.0)
- ⚠️ Web & Desktop (Camera support terbatas)

## 🎨 Design

- Material Design 3
- Google Fonts (Poppins)
- Teal/Green color scheme untuk tema kesehatan

## 📝 Catatan

- Data user **TIDAK** disimpan ke server
- Data hanya tersimpan lokal di device (SharedPreferences)
- Koneksi internet diperlukan untuk mengakses API Open Food Facts
- Akurasi analisis bergantung pada kelengkapan data produk di database

## 🤝 Contributing

Contributions, issues, dan feature requests sangat diterima!

## 📄 License

This project is open source.

## 👨‍💻 Developer

Dibuat dengan ❤️ menggunakan Flutter

---

**Note**: Aplikasi ini adalah alat bantu dan **bukan pengganti konsultasi medis profesional**. Selalu konsultasikan dengan dokter atau ahli gizi untuk keputusan kesehatan penting.

