# Troubleshooting Guide

## Common Issues & Solutions

### 1. Build Errors

#### Issue: "Target of URI doesn't exist"
**Cause:** Missing import atau typo di path
**Solution:**
```bash
flutter clean
flutter pub get
```

#### Issue: "Gradle build failed" (Android)
**Cause:** Gradle configuration atau SDK version
**Solution:**
1. Update Android SDK di Android Studio
2. Check `android/build.gradle.kts`:
   ```kotlin
   compileSdk = 34
   minSdk = 21
   ```
3. Run: `cd android && ./gradlew clean`

#### Issue: "CocoaPods error" (iOS)
**Cause:** Pod dependencies
**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### 2. Runtime Errors

#### Issue: Camera Permission Denied
**Android:**
- Check `AndroidManifest.xml` has camera permission
- Go to Settings → Apps → FoodFect → Permissions → Enable Camera

**iOS:**
- Check `Info.plist` has NSCameraUsageDescription
- Go to Settings → Privacy → Camera → Enable for FoodFect

**Code fix:**
```dart
// Request permission manually if needed
import 'package:permission_handler/permission_handler.dart';

final status = await Permission.camera.request();
if (!status.isGranted) {
  // Show dialog
}
```

#### Issue: "Product not found" for valid barcode
**Causes:**
1. Internet connection issue
2. Product not in Open Food Facts database
3. Invalid barcode format

**Solutions:**
1. Check internet connection
2. Verify barcode on Open Food Facts website:
   `https://world.openfoodfacts.org/product/{barcode}`
3. Try manual input instead of scanning

#### Issue: App crashes on scan
**Debug:**
```dart
// Add try-catch in barcode_scanner_screen.dart
try {
  final product = await _foodApiService.getProductByBarcode(barcode);
  // ... rest of code
} catch (e, stackTrace) {
  print('Error: $e');
  print('Stack: $stackTrace');
}
```

### 3. API Issues

#### Issue: HTTP Request Timeout
**Cause:** Slow internet or API down
**Solution:**
```dart
// In food_api_service.dart
final response = await http.get(url).timeout(
  Duration(seconds: 30),
  onTimeout: () {
    throw TimeoutException('Request timeout');
  },
);
```

#### Issue: "Invalid JSON response"
**Cause:** API returned error HTML instead of JSON
**Debug:**
```dart
print('Response body: ${response.body}');
final data = json.decode(response.body);
```

#### Issue: Null nutriments
**Not an error!** 
- Some products don't have complete nutrition data
- App handles this with null-safe operators (?)
- Just show "Data tidak tersedia"

### 4. UI Issues

#### Issue: Keyboard overlaps input fields
**Solution:** Already handled with `windowSoftInputMode` in AndroidManifest
If still issue:
```dart
// Wrap form in SingleChildScrollView
SingleChildScrollView(
  child: Form(...),
)
```

#### Issue: Images not loading
**Causes:**
1. Network image URL invalid
2. No internet
3. CORS issue (web only)

**Solution:**
```dart
Image.network(
  imageUrl,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return CircularProgressIndicator();
  },
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.error);
  },
)
```

#### Issue: Text overflow
**Solution:** Already handled with:
- `maxLines` + `overflow: TextOverflow.ellipsis`
- `Expanded` widgets in Rows
- `SingleChildScrollView` for long content

### 5. Data Issues

#### Issue: User data not persisting
**Check:**
```dart
// Verify save
final prefs = await SharedPreferences.getInstance();
final saved = await prefs.setString('user_profile', jsonData);
print('Saved: $saved');

// Verify load
final data = prefs.getString('user_profile');
print('Loaded: $data');
```

**Clear if corrupted:**
```dart
await prefs.remove('user_profile');
```

#### Issue: BMI calculation incorrect
**Verify formula:**
```dart
// BMI = weight(kg) / (height(m))^2
final bmi = weight / ((height / 100) * (height / 100));
```

**Test:**
- Weight: 70kg, Height: 170cm
- Expected BMI: 24.22
- Formula: 70 / (1.7 * 1.7) = 24.22 ✓

### 6. Performance Issues

#### Issue: Scanner lag
**Solutions:**
1. Lower camera resolution (if mobile_scanner supports)
2. Reduce overlay complexity
3. Add debouncing to prevent multiple scans

```dart
// Add debounce
Timer? _debounce;

void _handleBarcode(BarcodeCapture capture) {
  if (_debounce?.isActive ?? false) return;
  
  _debounce = Timer(Duration(milliseconds: 500), () {
    // Process barcode
  });
}
```

#### Issue: Slow API response
**Solutions:**
1. Add loading indicators (already done)
2. Implement caching
3. Use lower resolution images

```dart
// Add cache
final Map<String, FoodProduct> _cache = {};

Future<FoodProduct?> getProductByBarcode(String barcode) async {
  if (_cache.containsKey(barcode)) {
    return _cache[barcode];
  }
  
  final product = await _fetchFromAPI(barcode);
  _cache[barcode] = product;
  return product;
}
```

### 7. Testing Issues

#### Issue: Can't test without physical device
**Solutions:**
1. Use Android Emulator with camera support
2. Use manual barcode input screen
3. Create mock data for UI testing

```dart
// Mock data for testing
final mockProduct = FoodProduct(
  barcode: '123456789',
  productName: 'Test Product',
  brands: 'Test Brand',
  nutriments: Nutriments(
    energyKcal: 200,
    proteins: 5,
    carbohydrates: 30,
    fat: 8,
    sugars: 10,
    salt: 0.5,
  ),
  ingredients: [],
  allergens: ['gluten'],
  nutriscoreGrade: 'b',
  additives: [],
);
```

#### Issue: Emulator camera not working
**Android Emulator Settings:**
1. Open Emulator
2. Settings → Camera
3. Select "Webcam" or "Virtual Scene"

**Alternative:** Use manual input screen!

### 8. Deployment Issues

#### Issue: App crashes on release build
**Causes:**
1. Proguard rules stripping necessary code
2. Missing permissions in release
3. HTTP vs HTTPS in release

**Solutions:**

**Android - proguard-rules.pro:**
```
-keep class com.google.** { *; }
-keep class io.flutter.** { *; }
```

**Android - AndroidManifest.xml:**
```xml
<!-- Allow HTTP in debug only -->
<application
  android:usesCleartextTraffic="true">
```

**iOS - Info.plist:**
```xml
<!-- Allow HTTP (if needed) -->
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

#### Issue: APK size too large
**Solutions:**
```bash
# Build with splits
flutter build apk --split-per-abi

# Results in smaller APKs:
# - app-armeabi-v7a-release.apk
# - app-arm64-v8a-release.apk
# - app-x86_64-release.apk
```

### 9. Development Issues

#### Issue: Hot reload not working
**Solutions:**
1. Use hot restart instead (Shift+R in terminal)
2. Stop and restart app
3. Check for syntax errors

#### Issue: Dependencies conflict
**Check:**
```bash
flutter pub outdated
flutter pub upgrade
```

**Force resolve:**
```bash
flutter clean
rm -rf ~/.pub-cache
flutter pub get
```

### 10. Debugging Tips

#### Enable verbose logging
```bash
flutter run -v
```

#### Check device logs
**Android:**
```bash
adb logcat | grep flutter
```

**iOS:**
```bash
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "Runner"'
```

#### Add debug prints
```dart
print('DEBUG: Barcode scanned: $barcode');
debugPrint('API Response: ${response.body}');
```

#### Use Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## Getting Help

### Before asking for help:
1. ✅ Check this troubleshooting guide
2. ✅ Read error message carefully
3. ✅ Search error on Google/StackOverflow
4. ✅ Check Flutter/package documentation
5. ✅ Try `flutter clean && flutter pub get`

### Where to ask:
- Flutter Discord: https://discord.gg/flutter
- StackOverflow: Tag `flutter` + `dart`
- GitHub Issues: For package-specific problems

### Include in your question:
- Flutter version: `flutter --version`
- Error message (full stack trace)
- Code that causes issue
- What you've tried
- Expected vs actual behavior

## Useful Commands

```bash
# Check Flutter setup
flutter doctor -v

# Clean build
flutter clean

# Update dependencies
flutter pub get
flutter pub upgrade

# Build release
flutter build apk --release
flutter build ios --release

# Run with profile mode
flutter run --profile

# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test
```

---

**Need more help?** Check:
- [README.md](README.md) - Getting started
- [API_TESTING.md](API_TESTING.md) - API documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) - Code structure
