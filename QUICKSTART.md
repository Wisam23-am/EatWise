# FoodFect - Quick Start Guide

## 🚀 Setup dalam 5 Menit

### Prasyarat
- Flutter SDK 3.10.7+ terinstall
- Android Studio / VS Code
- Android device atau emulator dengan kamera

### Step-by-Step

#### 1. Clone & Setup (2 menit)
```bash
# Clone project (atau download zip)
cd c:\Project\foodfect

# Install dependencies
flutter pub get

# Verify setup
flutter doctor
```

#### 2. Run Aplikasi (1 menit)
```bash
# Connect device atau start emulator
flutter devices

# Run app
flutter run
```

**Atau dari VS Code:**
- Press `F5`
- Select device
- Wait for build

#### 3. Izinkan Permission (30 detik)
Saat diminta, izinkan:
- ✅ Camera permission (untuk scan barcode)

#### 4. Test Aplikasi (2 menit)

**First Run:**
1. Tap "Mulai Sekarang"
2. Isi data kesehatan:
   - Umur: 30
   - Berat: 70 kg
   - Tinggi: 170 cm
   - Gender: Laki-laki
   - Activity: Sedang
   - Goal: Maintain
3. Tap "Lanjut ke Scanner"

**Scan Product:**
Option A - **Scan Barcode Fisik:**
- Arahkan kamera ke barcode produk
- Tunggu deteksi otomatis

Option B - **Manual Input (Recommended untuk test):**
- Tap icon keyboard (⌨️) di kanan atas
- Masukkan barcode test: `8998866200486`
- Tap "Cari Produk"

**Lihat Hasil:**
- ✅ Status Aman/Tidak Aman
- 📊 Skor Kesesuaian
- ⚠️ Peringatan (jika ada)
- 💡 Rekomendasi
- 📋 Info Nutrisi

---

## 🎯 Quick Test Scenarios

### Test 1: Normal User (2 menit)
```
Profile:
- Umur: 25
- Berat: 65 kg
- Tinggi: 165 cm
- Tanpa penyakit
- Tanpa alergi
- Goal: Maintain

Barcode: 8998866200486 (Indomie)
Expected: Aman tapi ada warning sodium untuk maintain weight
```

### Test 2: Diabetic User (2 menit)
```
Profile:
- Umur: 45
- Berat: 75 kg
- Tinggi: 170 cm
- Riwayat: Diabetes
- Goal: Diet

Barcode: 5449000000996 (Coca Cola)
Expected: ⚠️ TIDAK DISARANKAN - High sugar warning
```

### Test 3: Allergy Check (2 menit)
```
Profile:
- Umur: 20
- Berat: 60 kg
- Tinggi: 160 cm
- Alergi: Kacang, Susu
- Goal: Bulking

Barcode: 3017620422003 (Nutella)
Expected: ⚠️ TIDAK DISARANKAN - Allergy warning
```

---

## 📱 Emulator Setup (jika tidak punya device)

### Android Emulator
```bash
# Create AVD dengan kamera
# Android Studio → AVD Manager → Create Virtual Device
# Select device: Pixel 6
# Select system image: API 34 (Latest)
# Advanced Settings:
#   - Camera Front: Webcam0
#   - Camera Back: VirtualScene
```

### Testing tanpa Kamera
Gunakan **Manual Input Screen**:
1. Di scanner, tap icon keyboard
2. Input barcode manual
3. Test semua fitur tanpa scan fisik

---

## 🔧 Development Tips

### Hot Reload
```bash
# Saat app running, press 'r' untuk hot reload
# Press 'R' untuk hot restart
```

### Debug Mode
```dart
// Add debug print di food_analyzer.dart
print('Analysis Score: ${result.overallScore}');
print('Warnings: ${result.warnings.length}');
```

### Clear Cache
```dart
// Di user_data_screen.dart, tambah tombol:
TextButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Restart app
  },
  child: Text('Clear Data'),
)
```

---

## 📖 Barcode untuk Testing

### Produk Indonesia
| Produk | Barcode | Test Case |
|--------|---------|-----------|
| Indomie Goreng | 8998866200486 | High sodium |
| Aqua | 8991002010017 | Healthy choice |
| Teh Botol | 8992753100114 | Moderate sugar |

### Produk International
| Produk | Barcode | Test Case |
|--------|---------|-----------|
| Nutella | 3017620422003 | Nuts, sugar |
| Coca Cola | 5449000000996 | High sugar |
| KitKat | 5000159484725 | Sugar, calories |
| Oreo | 7622210449283 | Sugar, fat |

### Where to Find More
- Open Food Facts: https://world.openfoodfacts.org
- Search any product
- Get barcode from URL

---

## ❓ Troubleshooting Cepat

### App tidak build?
```bash
flutter clean
flutter pub get
flutter run
```

### Camera tidak muncul?
- Check permission di settings device
- Restart app
- Try manual input screen

### Product tidak ditemukan?
- Cek koneksi internet
- Verify barcode di website Open Food Facts
- Try different product

### Error dependencies?
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

---

## 📚 Dokumentasi Lengkap

Setelah quick start, baca dokumentasi detail:

1. **[README.md](README.md)** - Overview & Installation
2. **[FEATURES.md](FEATURES.md)** - Fitur lengkap & Screenshots
3. **[ARCHITECTURE.md](ARCHITECTURE.md)** - Struktur kode
4. **[API_TESTING.md](API_TESTING.md)** - Testing & API docs
5. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Problem solving

---

## 🎓 Learning Path

### Beginner (Week 1)
- ✅ Setup & run app
- ✅ Test dengan manual input
- ✅ Pahami flow aplikasi
- ✅ Coba berbagai skenario test

### Intermediate (Week 2)
- 📖 Baca ARCHITECTURE.md
- 🔍 Explore source code
- ✏️ Modify UI colors/text
- 🧪 Add custom medical conditions

### Advanced (Week 3)
- 🏗️ Refactor code structure
- 🧩 Add new features
- 🧪 Write unit tests
- 📦 Add state management

---

## 🤝 Contribution

Ingin improve aplikasi?

1. Fork repository
2. Create feature branch: `git checkout -b feature/AmazingFeature`
3. Commit changes: `git commit -m 'Add AmazingFeature'`
4. Push to branch: `git push origin feature/AmazingFeature`
5. Open Pull Request

---

## 🎉 Next Steps

Setelah quick start berhasil:

1. ✅ Test dengan barcode produk nyata
2. ✅ Customize untuk kebutuhan spesifik
3. ✅ Deploy ke device untuk daily use
4. ✅ Share dengan teman/keluarga
5. ✅ Contribute improvements

---

## 💬 Support

Butuh bantuan?

- 📖 Baca [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- 💬 Open GitHub Issue
- 📧 Contact developer

---

**Happy Coding! 🚀**

**Selamat menggunakan FoodFect!**
