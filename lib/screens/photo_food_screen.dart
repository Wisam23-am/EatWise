import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/gemini_food_recognition_service.dart';
import 'result_screen.dart';

class PhotoFoodScreen extends StatefulWidget {
  final UserProfile userProfile;

  const PhotoFoodScreen({super.key, required this.userProfile});

  @override
  State<PhotoFoodScreen> createState() => _PhotoFoodScreenState();
}

class _PhotoFoodScreenState extends State<PhotoFoodScreen> {
  final _geminiService = GeminiFoodRecognitionService();
  final _picker = ImagePicker();
  File? _imageFile;
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
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
        _showError('Gagal mengenali makanan. Coba foto yang lebih jelas.');
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              userProfile: widget.userProfile,
              foodProduct: foodProduct,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_imageFile != null) ...[
                  Container(
                    height: 300,
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ] else ...[
                  Icon(Icons.camera_alt, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Ambil atau Upload Foto Makanan',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ],
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera),
                      label: Text('Foto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library),
                      label: Text('Galeri'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Menganalisis makanan...\nMohon tunggu',
                      style: GoogleFonts.poppins(color: Colors.white),
                      textAlign: TextAlign.center,
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