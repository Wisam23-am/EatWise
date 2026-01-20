# EatWise - App Features & Screenshots

## 🎯 Main Features

### 1. Home Screen
- **Splash/Landing Page** dengan branding aplikasi
- Tiga fitur utama dijelaskan dengan icon
- Tombol "Mulai Sekarang" untuk memulai
- Detect cached user profile otomatis

**Flow:**
```
First Time User → "Mulai Sekarang"
Returning User → "Mulai Scan Makanan" (skip data input)
```

---

### 2. User Data Input Screen
Form lengkap untuk input data kesehatan:

#### Data Dasar
- 📝 **Umur** (tahun) - Validasi: 1-120
- ⚖️ **Berat Badan** (kg) - Validasi: 20-300
- 📏 **Tinggi Badan** (cm) - Validasi: 50-250
- 👤 **Jenis Kelamin** - Dropdown: Laki-laki/Perempuan

#### Aktivitas & Tujuan
- 🏃 **Level Aktivitas** - Dropdown: Rendah/Sedang/Tinggi
- 🎯 **Tujuan** - Dropdown: Diet/Maintain/Bulking

#### Riwayat Kesehatan
- 🏥 **Riwayat Penyakit** - Multi-select chips:
  - Diabetes
  - Hipertensi
  - Kolesterol Tinggi
  - Obesitas
  - Asam Urat
  - Maag

- 🥜 **Alergi Makanan** - Multi-select chips:
  - Kacang
  - Susu
  - Telur
  - Ikan
  - Udang
  - Gandum
  - Kedelai

**Calculations (Auto):**
- BMI Calculator (Harris-Benedict)
- Daily Calorie Needs

**Features:**
- ✅ Form validation lengkap
- 💾 Auto-save to SharedPreferences
- 🔄 Edit data tersimpan

---

### 3. Barcode Scanner Screen
Real-time camera scanner dengan overlay UI:

**Controls:**
- 🔦 Toggle Flashlight/Torch
- 🔄 Switch Camera (Front/Back)
- ⌨️ Manual Input (untuk testing)

**Features:**
- Live camera preview
- Visual scan area (white border box)
- Instruction text: "Arahkan kamera ke barcode makanan"
- Loading overlay saat fetch API
- Prevent duplicate scans

**Supported Formats:**
- EAN-13 (most common)
- EAN-8
- UPC-A
- UPC-E
- Code-128
- QR Code (if available)

---

### 4. Manual Barcode Input Screen
Alternative untuk testing tanpa scan:

**Features:**
- Text input field untuk barcode
- Sample barcode chips (clickable):
  - Nutella: 3017620422003
  - Coca Cola: 5449000000996
  - Indomie: 8998866200486
- Loading state button
- Error handling & feedback

**Use Cases:**
- Testing without physical products
- Device without camera
- Debugging specific barcodes

---

### 5. Result/Analysis Screen
Comprehensive analysis display:

#### Product Card
- 📷 Product image (with fallback)
- 📦 Product name & brand
- 🏅 Nutriscore badge (A-E)

#### Safety Score Card
**Large status indicator:**
- ✅ **Aman Dikonsumsi** (Green) - No HIGH warnings
- ⚠️ **Tidak Disarankan** (Red) - Has HIGH warnings

**Score Display:**
- Numerical score: 0-100
- Category: Sangat Baik → Tidak Disarankan

#### Warnings Section (if any)
Color-coded warning cards:

**🔴 HIGH Severity (Red):**
- Alergi detected
- Tinggi gula (Diabetes)
- Tinggi natrium (Hipertensi)
- Tinggi lemak jenuh (Kolesterol)

**🟠 MEDIUM Severity (Orange):**
- Perhatian kadar gula/garam
- Bahan tambahan berisiko
- Nutriscore D-E

**🔵 LOW Severity (Blue):**
- Informasi kalori untuk diet
- Recommendations untuk goal

#### Recommendations Section
Positive suggestions berdasarkan profile:
- ✅ Tinggi serat (untuk diet)
- ✅ Tinggi protein (untuk bulking)
- ✅ Nutriscore A-B
- ✅ Sesuai kebutuhan kalori

#### Nutrition Info Card
Detailed per 100g:
- 🔥 Kalori (kcal)
- 🥩 Protein (g)
- 🍞 Karbohidrat (g)
  - 🍬 Gula (g)
- 🧈 Lemak (g)
  - 🥓 Lemak Jenuh (g)
- 🌾 Serat (g)
- 🧂 Garam (g)

#### User Profile Summary
Your data for reference:
- BMI & Category
- Daily Calorie Needs
- Goal
- Medical Conditions
- Allergies

**Actions:**
- 🔄 **Scan Produk Lain** - Back to scanner
- ⬅️ **Back Button** - Back to scanner

---

## 🎨 Design System

### Color Palette
- **Primary:** Teal/Green (`Colors.teal`)
- **Accent:** Green (`Colors.green`)
- **Warning:** Orange/Red (`Colors.orange/red`)
- **Background:** White/Light gray
- **Text:** Dark gray

### Typography
- **Font Family:** Poppins (via Google Fonts)
- **Title:** Bold, 18-24px
- **Body:** Regular, 13-16px
- **Small:** 11-12px

### Components
- **Cards:** Rounded (12px), Shadow elevation 3
- **Buttons:** Rounded (12px), Full width
- **Chips:** Rounded (20px), Selectable
- **Inputs:** Rounded (12px), Border outline

### Icons
- Material Icons
- Size: 20-80px depending on context
- Color matches component theme

---

## 📱 User Experience Flow

```
┌─────────────────┐
│   Home Screen   │
│   (Landing)     │
└────────┬────────┘
         │
    [Start Button]
         │
         ↓
┌─────────────────┐
│  User Data      │
│  Input Form     │ ← Can load cached data
└────────┬────────┘
         │
   [Save & Continue]
         │
         ↓
┌─────────────────┐
│  Barcode        │
│  Scanner        │ ← [Manual Input] option
└────────┬────────┘
         │
    [Scan Success]
         │
         ↓
    [API Call]
         │
         ↓
┌─────────────────┐
│  Result &       │
│  Analysis       │
└────────┬────────┘
         │
    [Scan Again]
         │
         └──────→ Back to Scanner
```

---

## 💡 Smart Analysis Logic

### Input: User Profile + Food Product
### Output: Safety Status + Warnings + Recommendations + Score

**Analysis Steps:**

1. **Allergy Check** ⚠️ HIGH
   - Cross-check allergens tags
   - Check ingredients text
   - Exact & partial matching

2. **Medical Conditions** ⚠️ HIGH/MEDIUM
   - Diabetes → Check sugar content
   - Hipertensi → Check sodium/salt
   - Kolesterol → Check saturated fat
   - Obesitas → Check calories

3. **Goal Alignment** ℹ️ LOW
   - Diet → Prefer low calorie, high fiber
   - Maintain → Balanced nutrition
   - Bulking → Prefer high protein, high calorie

4. **Quality Assessment** ℹ️
   - Nutriscore A-E rating
   - Natural vs processed

5. **Additives Check** ⚠️ MEDIUM
   - Harmful E-numbers
   - MSG, preservatives, artificial colors

**Scoring Algorithm:**
```
Base Score: 100
- HIGH warning: -30 points
- MEDIUM warning: -15 points
- LOW warning: -5 points

Final Score: Clamped to 0-100
```

**Safety Determination:**
```
isSafe = (No HIGH warnings)
```

---

## 🚀 Performance & UX

### Loading States
- ⏳ Splash screen (home)
- ⏳ Form submission
- ⏳ Scanner processing
- ⏳ API fetch
- ⏳ Manual search

### Error Handling
- ❌ Network errors
- ❌ Product not found
- ❌ Invalid barcode
- ❌ Permission denied
- ❌ Validation errors

### Optimizations
- Prevent duplicate scans (debouncing)
- Cache user profile locally
- Dispose controllers properly
- Null-safe everywhere
- Graceful degradation

### Accessibility
- Clear labels
- High contrast colors
- Large touch targets (min 48px)
- Descriptive error messages
- Loading indicators

---

## 📊 Example Scenarios

### Scenario 1: Healthy User, Good Product
**User:** 25 years, Normal BMI, No conditions, Goal: Maintain
**Product:** Fresh Milk (Low sugar, Good nutrients)
**Result:** ✅ Aman Dikonsumsi (Score: 95)
**Warnings:** None
**Recommendations:** Good source of protein and calcium

### Scenario 2: Diabetic User, Sugary Drink
**User:** 45 years, Diabetes
**Product:** Coca Cola (High sugar: 10.6g/100ml)
**Result:** ⚠️ Tidak Disarankan (Score: 40)
**Warnings:** 🔴 Tinggi Gula - Tidak disarankan untuk penderita diabetes
**Recommendations:** Choose sugar-free alternatives

### Scenario 3: Hypertension, Instant Noodles
**User:** 50 years, Hipertensi
**Product:** Indomie (High sodium: 1.15g/100g)
**Result:** ⚠️ Tidak Disarankan (Score: 55)
**Warnings:** 🔴 Tinggi Natrium - Tidak disarankan untuk penderita hipertensi
**Recommendations:** Limit portion, avoid seasoning

### Scenario 4: Nut Allergy, Chocolate Spread
**User:** Any age, Alergi: Kacang
**Product:** Nutella (Contains: hazelnuts)
**Result:** ⚠️ Tidak Disarankan (Score: 0)
**Warnings:** 🔴 PERINGATAN ALERGI! Produk mengandung kacang
**Recommendations:** None (unsafe)

---

## 🎯 Key Selling Points

1. **No Registration Required** - Privacy-focused
2. **Instant Analysis** - Scan and get results in seconds
3. **Personalized** - Based on YOUR health profile
4. **Comprehensive** - Checks allergies, conditions, goals
5. **Educational** - Learn about nutrition
6. **Free API** - Powered by Open Food Facts
7. **Offline-ready Data** - Cache your profile
8. **Testing-friendly** - Manual input for demos

---

## 📈 Future Features (Ideas)

- [ ] Scan history & favorites
- [ ] Barcode scanning from gallery
- [ ] Product comparison (vs alternatives)
- [ ] Share results with doctor
- [ ] Export PDF report
- [ ] Recipe suggestions
- [ ] Daily nutrition tracker
- [ ] OCR for nutrition labels
- [ ] Voice feedback
- [ ] Dark mode
- [ ] Multi-language support

---

**Created with ❤️ for health-conscious users**
