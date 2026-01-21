// ... imports ...
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/common_widgets.dart';
import '../services/gemini_food_recognition_service.dart';
import 'result_screen.dart';
import 'barcode_scanner_screen.dart';

class PhotoFoodScreen extends StatefulWidget {
  const PhotoFoodScreen({super.key});

  @override
  State<PhotoFoodScreen> createState() => _PhotoFoodScreenState();
}

class _PhotoFoodScreenState extends State<PhotoFoodScreen> {
  // ... variables ...
  final _geminiService = GeminiFoodRecognitionService();
  final _picker = ImagePicker();
  File? _imageFile;
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    // ... implementation same ...
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;
    setState(() => _isProcessing = true);

    try {
      final foodProduct = await _geminiService.recognizeFood(_imageFile!);
      if (foodProduct == null) {
        _showError('Gagal mengenali makanan.');
        return;
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(foodProduct: foodProduct),
          ),
        );
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Foto Makanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const BarcodeScannerScreen()),
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_imageFile != null) ...[
                  // 3. HERO PADA PHOTO PREVIEW
                  Hero(
                    tag:
                        'photo_scan', // Tag ini sama dengan fallback di ResultScreen
                    child: Container(
                      height: 300,
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.camera_alt, size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'Ambil atau Upload Foto Makanan',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ],
                // ... Buttons ...
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera),
                      label: const Text('Foto'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // SKELETON LOADING OVERLAY (Full Screen)
          if (_isProcessing)
            const Positioned.fill(
              child: ResultSkeletonOverlay(), // Gunakan skeleton yang sama
            ),
        ],
      ),
    );
  }
}
