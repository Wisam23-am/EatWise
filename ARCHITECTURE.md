# Arsitektur & Struktur Kode

## Overview

Aplikasi menggunakan arsitektur sederhana dengan pemisahan concerns:
- **Models**: Data structures
- **Services**: Business logic & API calls
- **Screens**: UI components

## File Structure Detail

### 📁 models/

#### user_profile.dart
**Purpose:** Model data user dengan health calculations

**Key Features:**
- Properties: age, weight, height, gender, medical conditions, allergies, activity level, goal
- BMI calculation & categorization
- Daily calorie needs (Harris-Benedict formula)
- JSON serialization for SharedPreferences

**Usage:**
```dart
final user = UserProfile(
  age: 30,
  weight: 70,
  height: 170,
  gender: 'Laki-laki',
  medicalConditions: ['Diabetes'],
  allergies: ['Kacang'],
  activityLevel: 'Sedang',
  goal: 'Diet',
);

print(user.bmi); // 24.22
print(user.bmiCategory); // "Normal"
print(user.dailyCalorieNeeds); // ~2200
```

#### food_product.dart
**Purpose:** Model produk dari Open Food Facts API

**Key Classes:**
1. **FoodProduct**: Main product data
   - barcode, name, brands, image
   - nutriments, ingredients, allergens
   - nutriscore, additives, categories

2. **Nutriments**: Nutritional values per 100g
   - energy (kcal), proteins, carbs, sugars
   - fat, saturated fat, fiber, salt, sodium

**Parsing Features:**
- Handles missing/null data safely
- Converts various data types (List, String, dynamic)
- Cleans allergen tags (removes "en:" prefix)

### 📁 services/

#### food_api_service.dart
**Purpose:** HTTP client untuk Open Food Facts API

**Methods:**

1. `getProductByBarcode(String barcode)`
   - Returns: `Future<FoodProduct?>`
   - Null jika produk tidak ditemukan
   - Throw exception jika network error

2. `searchProducts(String query)`
   - Returns: `Future<List<FoodProduct>>`
   - Max 10 results
   - Empty list jika error

**Error Handling:**
- Try-catch semua network calls
- Print error untuk debugging
- Return null/empty instead of throwing

#### food_analyzer.dart
**Purpose:** Core analysis engine

**Main Function:**
```dart
AnalysisResult analyzeFoodSuitability(UserProfile user, FoodProduct food)
```

**Analysis Steps:**
1. Check allergies → HIGH severity
2. Check medical conditions → HIGH/MEDIUM
3. Check nutrition vs goals → LOW/Recommendations
4. Check nutriscore quality → Info
5. Check harmful additives → MEDIUM

**Output Classes:**

1. **AnalysisResult**
   - isSafe: bool (no HIGH warnings)
   - warnings: List<Warning>
   - recommendations: List<String>
   - overallScore: double (0-100)
   - scoreCategory: String

2. **Warning**
   - title: String
   - message: String
   - severity: WarningSeverity (high/medium/low)

### 📁 screens/

#### home_screen.dart
**Purpose:** Landing page

**Features:**
- Display app features
- Load cached user profile
- Navigate to user data input

**State Management:**
- StatefulWidget untuk load cache
- SharedPreferences.getString('user_profile')

#### user_data_screen.dart
**Purpose:** User health data input form

**Form Fields:**
- TextFields: age, weight, height (with validation)
- Dropdowns: gender, activity level, goal
- FilterChips: medical conditions, allergies

**Validation:**
- Age: 1-120
- Weight: 20-300 kg
- Height: 50-250 cm
- All required except conditions/allergies

**Data Flow:**
1. User fills form
2. Validate inputs
3. Create UserProfile object
4. Save to SharedPreferences
5. Navigate to scanner

**Cache Feature:**
- Load existing profile on init
- Pre-fill form if available
- Update button text ("Mulai Scan" vs "Mulai Sekarang")

#### barcode_scanner_screen.dart
**Purpose:** Camera-based barcode scanner

**Dependencies:**
- mobile_scanner package
- MobileScannerController

**Features:**
- Real-time barcode detection
- Torch (flashlight) toggle
- Camera flip (front/back)
- Manual input button (keyboard icon)

**Scan Flow:**
1. Detect barcode from camera
2. Prevent duplicate scans (_isProcessing flag)
3. Call API to get product
4. Show loading indicator
5. Navigate to result or show error

**Error Handling:**
- Product not found → AlertDialog
- API error → AlertDialog with error message
- Processing flag prevents spam

#### manual_barcode_screen.dart
**Purpose:** Testing alternative - manual barcode input

**Features:**
- TextField untuk input barcode
- Sample barcode chips (clickable)
- Loading state saat fetch API

**Sample Barcodes:**
- Nutella: 3017620422003
- Coca Cola: 5449000000996
- Indomie: 8998866200486

**Use Case:**
- Testing without physical products
- Device without camera
- Debugging specific products

#### result_screen.dart
**Purpose:** Display analysis results

**Sections:**

1. **Product Card**
   - Image (with fallback placeholder)
   - Name & brand
   - Nutriscore badge

2. **Score Card**
   - Safe/Unsafe status (icon & color)
   - Overall score (0-100)
   - Score category (Sangat Baik - Tidak Disarankan)

3. **Warnings Card** (if any)
   - Icon by severity (error/warning/info)
   - Color-coded containers
   - Title & detailed message

4. **Recommendations Card** (if any)
   - Green checkmarks
   - Positive suggestions

5. **Nutrition Card**
   - All available nutriments
   - Per 100g values
   - Formatted to 1-2 decimal places

6. **User Summary Card**
   - BMI & category
   - Daily calorie needs
   - Goal & conditions

**Navigation:**
- Back button → Return to scanner
- Scan Again button → New scan session

**Color Coding:**
- Green: Safe, good recommendations
- Red: Unsafe, high warnings
- Orange: Medium warnings
- Blue: Low warnings (info)

## Data Flow

### Full User Journey

```
1. App Start
   ↓
2. Home Screen
   - Check cached profile
   ↓
3. User Data Screen
   - Input/Edit health data
   - Save to SharedPreferences
   ↓
4. Barcode Scanner Screen
   - Scan barcode OR
   - Manual input (keyboard icon)
   ↓
5. API Call
   - Fetch product from Open Food Facts
   ↓
6. Analysis
   - FoodAnalyzer.analyzeFoodSuitability()
   ↓
7. Result Screen
   - Display product info
   - Show warnings/recommendations
   - Show nutrition
   ↓
8. Actions
   - Scan Again → Back to Scanner
   - Back Button → Back to Scanner
```

### State Management

**No State Management Library Used**
- Simple StatefulWidget & setState
- Data passed via constructor parameters
- Cache via SharedPreferences

**State Locations:**
- User Profile: Passed through screens
- Food Product: Fetched & passed to result
- Scanner State: Local in scanner screen

## Key Design Decisions

### 1. No Database
- Requirement: No user accounts
- Solution: SharedPreferences for temp storage
- Data cleared on app uninstall

### 2. No Authentication
- Requirement: No registration
- Users input data each session (optional)
- Profile cache is convenience feature

### 3. Synchronous Navigation
- Each screen waits for user action
- No background processes
- Clear linear flow

### 4. Error Tolerance
- Null-safe everywhere (?)
- Handle missing API data gracefully
- Show errors without crashing

### 5. Offline Support
- None - requires internet for API
- Could add: Cache recent products
- Could add: Offline mode with limited features

## Performance Considerations

### API Calls
- Only on-demand (scan or search)
- No prefetching
- No caching (could be improved)

### Image Loading
- Network images with error handling
- Placeholder for missing images
- No image caching (handled by Flutter)

### Scanner
- Prevent duplicate scans with flag
- Dispose controller on screen exit
- Background process during scan

## Future Improvements

### Features
- [ ] Product cache for offline
- [ ] Scan history
- [ ] Favorites list
- [ ] Barcode history
- [ ] Share results
- [ ] Export PDF report

### Technical
- [ ] Add state management (Provider/Riverpod)
- [ ] Unit tests for analyzer logic
- [ ] Widget tests for screens
- [ ] API response caching
- [ ] Batch barcode scanning
- [ ] Product comparison

### UX
- [ ] Onboarding tutorial
- [ ] Dark mode
- [ ] Language support (i18n)
- [ ] Accessibility improvements
- [ ] Animation & transitions
- [ ] Sound feedback on scan

## Testing Strategy

### Manual Testing
1. Test all user input validations
2. Test with various barcodes
3. Test each medical condition scenario
4. Test allergy detection
5. Test offline behavior
6. Test camera permissions

### Automated Testing
```dart
// Example: Test BMI calculation
test('BMI calculation', () {
  final user = UserProfile(/* ... */);
  expect(user.bmi, closeTo(24.22, 0.01));
});

// Example: Test analyzer
test('Diabetes warning on high sugar', () {
  final result = FoodAnalyzer.analyzeFoodSuitability(
    diabeticUser,
    highSugarProduct,
  );
  expect(result.isSafe, false);
  expect(result.warnings.any((w) => w.severity == WarningSeverity.high), true);
});
```

## Dependencies Management

### Core Dependencies
- flutter: SDK
- http: ^1.2.2
- mobile_scanner: ^5.2.3
- shared_preferences: ^2.3.3
- google_fonts: ^6.2.1

### When to Update
- Security patches: Immediately
- Breaking changes: Plan migration
- New features: Evaluate benefit

### Compatibility
- Minimum Flutter: 3.10.7
- Android: SDK 21+ (Lollipop)
- iOS: 12.0+

---

**Documented by: FoodFect Development Team**
**Last Updated: January 2026**
