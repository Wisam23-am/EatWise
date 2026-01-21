import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart'; // Pastikan path ini sesuai
import 'barcode_scanner_screen.dart';
import '../widgets/common_widgets.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({super.key});

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk data fisik
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _gender = 'Laki-laki';
  String _activityLevel = 'Sedang';
  String _goal = 'Maintain';

  List<String> _selectedMedicalConditions = [];
  List<String> _selectedAllergies = [];

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
    // Load data terakhir dari Provider (Auto-fill) jika ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      if (provider.hasData && provider.userProfile != null) {
        final profile = provider.userProfile!;
        setState(() {
          _ageController.text = profile.age.toString();
          _weightController.text = profile.weight.toString();
          _heightController.text = profile.height.toString();
          _gender = profile.gender;
          _activityLevel = profile.activityLevel;
          _goal = profile.goal;
          // Buat list baru agar tidak referensi ke list lama
          _selectedMedicalConditions = List.from(profile.medicalConditions);
          _selectedAllergies = List.from(profile.allergies);
        });
      }
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _saveAndContinue() async {
    if (_formKey.currentState!.validate()) {
      // Membuat objek profil dari input form
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

      // SIMPAN ke Provider (dan SharedPreferences di dalamnya)
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).saveUserData(profile);

      if (!mounted) return;

      // Pindah ke Scanner TANPA membawa data profile di constructor
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Informasi Tubuh',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            FadeInSlide(
              delay: 0.1,
              child: Text(
                'Lengkapi data berikut agar kami dapat memberikan rekomendasi nutrisi yang tepat.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Data Fisik
            FadeInSlide(delay: 0.2, child: _buildSectionTitle('Data Fisik')),
            const SizedBox(height: 16),

            FadeInSlide(
              delay: 0.3,
              child: Row(
                children: [
                  Expanded(
                    child: _buildModernInput(
                      controller: _ageController,
                      label: 'Umur',
                      suffix: 'th',
                      validator: (v) => v!.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernInput(
                      controller: _weightController,
                      label: 'Berat',
                      suffix: 'kg',
                      validator: (v) => v!.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernInput(
                      controller: _heightController,
                      label: 'Tinggi',
                      suffix: 'cm',
                      validator: (v) => v!.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            FadeInSlide(
              delay: 0.4,
              child: _buildModernDropdown(
                label: 'Jenis Kelamin',
                value: _gender,
                items: ['Laki-laki', 'Perempuan'],
                onChanged: (v) => setState(() => _gender = v!),
              ),
            ),

            const SizedBox(height: 32),

            // Aktivitas & Tujuan
            FadeInSlide(delay: 0.5, child: _buildSectionTitle('Gaya Hidup')),
            const SizedBox(height: 16),

            FadeInSlide(
              delay: 0.6,
              child: _buildModernDropdown(
                label: 'Level Aktivitas',
                value: _activityLevel,
                items: ['Rendah', 'Sedang', 'Tinggi'],
                onChanged: (v) => setState(() => _activityLevel = v!),
              ),
            ),
            const SizedBox(height: 16),

            FadeInSlide(
              delay: 0.7,
              child: _buildModernDropdown(
                label: 'Target Kesehatan',
                value: _goal,
                items: ['Diet', 'Maintain', 'Bulking'],
                onChanged: (v) => setState(() => _goal = v!),
              ),
            ),

            const SizedBox(height: 32),

            // Riwayat Penyakit
            FadeInSlide(
              delay: 0.8,
              child: _buildSectionTitle('Kondisi Medis (Opsional)'),
            ),
            const SizedBox(height: 12),
            FadeInSlide(
              delay: 0.9,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _medicalConditionOptions.map((condition) {
                  final isSelected = _selectedMedicalConditions.contains(
                    condition,
                  );
                  return ChoiceChip(
                    label: Text(condition),
                    selected: isSelected,
                    selectedColor: Colors.teal.shade100,
                    labelStyle: GoogleFonts.poppins(
                      color: isSelected
                          ? Colors.teal.shade800
                          : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _selectedMedicalConditions.add(condition)
                            : _selectedMedicalConditions.remove(condition);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Alergi
            FadeInSlide(
              delay: 1.0,
              child: _buildSectionTitle('Alergi (Opsional)'),
            ),
            const SizedBox(height: 12),
            FadeInSlide(
              delay: 1.1,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allergyOptions.map((allergy) {
                  final isSelected = _selectedAllergies.contains(allergy);
                  return ChoiceChip(
                    label: Text(allergy),
                    selected: isSelected,
                    selectedColor: Colors.orange.shade100,
                    labelStyle: GoogleFonts.poppins(
                      color: isSelected
                          ? Colors.orange.shade800
                          : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _selectedAllergies.add(allergy)
                            : _selectedAllergies.remove(allergy);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),

            // Submit Button
            FadeInSlide(
              delay: 1.2,
              child: PrimaryButton(
                text: 'Simpan & Scan',
                onPressed: _saveAndContinue,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required String suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.teal.shade400, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
