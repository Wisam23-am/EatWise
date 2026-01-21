import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_data_screen.dart';
import '../widgets/common_widgets.dart'; // Pastikan widget animasi FadeInSlide ada di sini

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // 1. Hero Section (Logo & Tagline)
              FadeInSlide(
                delay: 0.2,
                child: Center(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.1),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 70,
                            color: Colors.teal.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'EatWise',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pindai. Analisis. Hidup Sehat.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // 2. Feature Cards (Modern List)
              FadeInSlide(
                delay: 0.3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Fitur Unggulan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              FadeInSlide(
                delay: 0.4,
                child: _buildModernFeatureCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Scan Barcode',
                  desc: 'Cek kandungan nutrisi instan',
                  color: Colors.blue.shade50,
                  iconColor: Colors.blue.shade600,
                ),
              ),

              const SizedBox(height: 16),

              FadeInSlide(
                delay: 0.5,
                child: _buildModernFeatureCard(
                  icon: Icons.analytics_outlined,
                  title: 'Analisis Kesehatan',
                  desc: 'Sesuaikan dengan kondisi tubuh',
                  color: Colors.orange.shade50,
                  iconColor: Colors.orange.shade600,
                ),
              ),

              const SizedBox(height: 60),

              // 3. Action Button
              FadeInSlide(
                delay: 0.6,
                child: PrimaryButton(
                  text: 'Mulai Sekarang',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    // Langsung ke input data tanpa cek profil
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserDataScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
