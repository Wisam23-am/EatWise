import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/user_profile.dart';
import '../services/food_api_service.dart';
import 'result_screen.dart';
import 'manual_barcode_screen.dart';
import 'photo_food_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final UserProfile userProfile;

  const BarcodeScannerScreen({super.key, required this.userProfile});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  final _foodApiService = OpenFoodFactsService();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // Ambil data produk dari API
      final product = await _foodApiService.getProductByBarcode(barcode);

      if (product == null) {
        if (mounted) {
          _showErrorDialog(
            'Produk tidak ditemukan',
            'Barcode $barcode tidak ditemukan dalam database.',
          );
        }
      } else {
        if (mounted) {
          // Navigasi ke result screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                userProfile: widget.userProfile,
                foodProduct: product,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', 'Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Barcode',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _scannerController.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard),
            tooltip: 'Input Manual',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ManualBarcodeScreen(userProfile: widget.userProfile),
                ),
              );
            },
          ),
          // Di actions AppBar, tambah:
          IconButton(
            icon: const Icon(Icons.photo_camera),
            tooltip: 'Foto Makanan',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PhotoFoodScreen(userProfile: widget.userProfile),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),
          // Overlay
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Column(
              children: [
                Expanded(child: Container()),
                // Scanner Area
                Container(
                  height: 250,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Arahkan kamera ke barcode makanan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          // Loading Indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'Mengambil data produk...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
