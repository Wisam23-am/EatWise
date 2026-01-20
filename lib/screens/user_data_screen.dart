import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'barcode_scanner_screen.dart';

class UserDataScreen extends StatefulWidget {
  final UserProfile? existingProfile;

  const UserDataScreen({super.key, this.existingProfile});

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _gender = 'Laki-laki';
  String _activityLevel = 'Sedang';
  String _goal = 'Maintain';

  final List<String> _selectedMedicalConditions = [];
  final List<String> _selectedAllergies = [];

  final List<String> _medicalConditionOptions = [
    'Diabetes',
    'Hipertensi',
    'Kolesterol Tinggi',
    'Obesitas',
    'Asam Urat',
    'Maag',
  ];

  final List<String> _allergyOptions = [
    'Kacang',
    'Susu',
    'Telur',
    'Ikan',
    'Udang',
    'Gandum',
    'Kedelai',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _loadExistingProfile();
    }
  }

  void _loadExistingProfile() {
    final profile = widget.existingProfile!;
    _ageController.text = profile.age.toString();
    _weightController.text = profile.weight.toString();
    _heightController.text = profile.height.toString();
    _gender = profile.gender;
    _activityLevel = profile.activityLevel;
    _goal = profile.goal;
    _selectedMedicalConditions.addAll(profile.medicalConditions);
    _selectedAllergies.addAll(profile.allergies);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        gender: _gender,
        medicalConditions: _selectedMedicalConditions,
        allergies: _selectedAllergies,
        activityLevel: _activityLevel,
        goal: _goal,
      );

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', json.encode(profile.toJson()));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BarcodeScannerScreen(userProfile: profile),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Kesehatan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Masukkan data kesehatan Anda untuk analisis yang lebih akurat',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Data Dasar
            _buildSectionTitle('Data Dasar'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration('Umur', 'tahun'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mohon masukkan umur';
                }
                final age = int.tryParse(value);
                if (age == null || age < 1 || age > 120) {
                  return 'Umur tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration('Berat Badan', 'kg'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mohon masukkan berat badan';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight < 20 || weight > 300) {
                  return 'Berat badan tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration('Tinggi Badan', 'cm'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mohon masukkan tinggi badan';
                }
                final height = double.tryParse(value);
                if (height == null || height < 50 || height > 250) {
                  return 'Tinggi badan tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: _buildInputDecoration('Jenis Kelamin', ''),
              items: [
                'Laki-laki',
                'Perempuan',
              ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (value) => setState(() => _gender = value!),
            ),

            const SizedBox(height: 24),

            // Aktivitas & Tujuan
            _buildSectionTitle('Aktivitas & Tujuan'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _activityLevel,
              decoration: _buildInputDecoration('Level Aktivitas', ''),
              items: [
                'Rendah',
                'Sedang',
                'Tinggi',
              ].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (value) => setState(() => _activityLevel = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _goal,
              decoration: _buildInputDecoration('Tujuan', ''),
              items: [
                'Diet',
                'Maintain',
                'Bulking',
              ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (value) => setState(() => _goal = value!),
            ),

            const SizedBox(height: 24),

            // Riwayat Penyakit
            _buildSectionTitle('Riwayat Penyakit'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _medicalConditionOptions.map((condition) {
                final isSelected = _selectedMedicalConditions.contains(
                  condition,
                );
                return FilterChip(
                  label: Text(condition),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMedicalConditions.add(condition);
                      } else {
                        _selectedMedicalConditions.remove(condition);
                      }
                    });
                  },
                  selectedColor: Colors.teal.shade100,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Alergi
            _buildSectionTitle('Alergi Makanan'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allergyOptions.map((allergy) {
                final isSelected = _selectedAllergies.contains(allergy);
                return FilterChip(
                  label: Text(allergy),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.add(allergy);
                      } else {
                        _selectedAllergies.remove(allergy);
                      }
                    });
                  },
                  selectedColor: Colors.orange.shade100,
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _saveAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lanjut ke Scanner',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String suffix) {
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
      ),
    );
  }
}
