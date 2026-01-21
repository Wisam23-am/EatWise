import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/food_api_service.dart';
import 'result_screen.dart';
import 'barcode_scanner_screen.dart'; // Import scanner untuk tombol back jika perlu

class ManualBarcodeScreen extends StatefulWidget {
  // HAPUS parameter userProfile
  const ManualBarcodeScreen({super.key});

  @override
  State<ManualBarcodeScreen> createState() => _ManualBarcodeScreenState();
}

class _ManualBarcodeScreenState extends State<ManualBarcodeScreen> {
  final _barcodeController = TextEditingController();
  final _foodApiService = OpenFoodFactsService();
  bool _isLoading = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _searchBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      _showError('Mohon masukkan barcode');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = await _foodApiService.getProductByBarcode(barcode);

      if (product == null) {
        _showError('Produk dengan barcode $barcode tidak ditemukan');
      } else {
        if (mounted) {
          // Navigasi ke ResultScreen TANPA userProfile
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(foodProduct: product),
            ),
          );
        }
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Input Barcode Manual',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Kembali ke scanner jika user menekan tombol back
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BarcodeScannerScreen(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 80, color: Colors.teal.shade300),
            const SizedBox(height: 24),
            Text(
              'Masukkan Barcode',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Untuk testing tanpa scan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Barcode',
                hintText: 'Contoh: 8998866200486',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _searchBarcode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Cari Produk',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Contoh barcode untuk testing:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSampleBarcode('3017620422003'), // Nutella
                _buildSampleBarcode('5449000000996'), // Coca Cola
                _buildSampleBarcode('8998866200486'), // Indomie
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleBarcode(String barcode) {
    return InkWell(
      onTap: () {
        _barcodeController.text = barcode;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal.shade200),
        ),
        child: Text(
          barcode,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.teal.shade700),
        ),
      ),
    );
  }
}
