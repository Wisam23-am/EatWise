import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Wajib untuk HapticFeedback
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/food_api_service.dart';
import '../widgets/common_widgets.dart'; // Import skeleton
import 'result_screen.dart';
import 'manual_barcode_screen.dart';
import 'photo_food_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

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

    // 1. Haptic Feedback (Getaran) saat scan berhasil
    HapticFeedback.mediumImpact();

    setState(() => _isProcessing = true);
    _scannerController.stop();

    try {
      final product = await _foodApiService.getProductByBarcode(barcode);

      if (product == null) {
        if (mounted) {
          // Getaran berbeda untuk error
          HapticFeedback.vibrate();
          _showNotFoundDialog(barcode);
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(foodProduct: product),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Koneksi Gagal', 'Periksa internet Anda. Error: $e');
        _scannerController.start();
      }
    } finally {
      if (mounted) {
        // Jangan set false jika sukses pindah layar, agar skeleton tidak hilang mendadak
        // Tapi di sini kita pushReplacement, jadi screen ini akan didispose.
        // Jika error/not found, baru kita perlu set false.
      }
    }
  }

  // ... (Method _showNotFoundDialog dan _showErrorDialog SAMA SEPERTI SEBELUMNYA) ...
  void _showNotFoundDialog(String barcode) {
    // Copy dari response sebelumnya
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search_off, size: 32, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Produk Tidak Ditemukan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Barcode $barcode belum ada di database kami. Coba metode lain:',
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManualBarcodeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.keyboard),
                    label: const Text('Input Manual'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PhotoFoodScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Foto Nutrisi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isProcessing = false);
                  _scannerController.start();
                },
                child: const Text('Coba Scan Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false);
              _scannerController.start();
            },
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManualBarcodeScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.photo_camera),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PhotoFoodScreen(),
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

          // Overlay UI (kotak scan)
          if (!_isProcessing)
            Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
              child: Column(
                children: [
                  Expanded(child: Container()),
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

          // 2. SKELETON LOADING OVERLAY (Full Screen)
          // Menggantikan spinner bulat hitam
          if (_isProcessing)
            const Positioned.fill(child: ResultSkeletonOverlay()),
        ],
      ),
    );
  }
}
