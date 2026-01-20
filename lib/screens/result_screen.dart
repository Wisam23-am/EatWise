import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';
import '../models/food_product.dart';
import '../services/food_analyzer.dart';
import 'barcode_scanner_screen.dart';

class ResultScreen extends StatelessWidget {
  final UserProfile userProfile;
  final FoodProduct foodProduct;

  const ResultScreen({
    super.key,
    required this.userProfile,
    required this.foodProduct,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = FoodAnalyzer.analyzeFoodSuitability(
      userProfile,
      foodProduct,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hasil Analisis',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Kembali ke scanner
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BarcodeScannerScreen(userProfile: userProfile),
              ),
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Product Card
          _buildProductCard(),
          const SizedBox(height: 16),

          // Overall Score
          _buildScoreCard(analysis),
          const SizedBox(height: 16),

          // Warnings
          if (analysis.warnings.isNotEmpty) ...[
            _buildWarningsCard(analysis.warnings),
            const SizedBox(height: 16),
          ],

          // Recommendations
          if (analysis.recommendations.isNotEmpty) ...[
            _buildRecommendationsCard(analysis.recommendations),
            const SizedBox(height: 16),
          ],

          // Nutrition Info
          if (foodProduct.nutriments != null) ...[
            _buildNutritionCard(foodProduct.nutriments!),
            const SizedBox(height: 16),
          ],

          // User Info Summary
          _buildUserSummaryCard(),
          const SizedBox(height: 16),

          // Scan Again Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BarcodeScannerScreen(userProfile: userProfile),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(
              'Scan Produk Lain',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            if (foodProduct.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  foodProduct.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
                ),
              )
            else
              _buildPlaceholderImage(),

            const SizedBox(width: 16),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodProduct.productName ?? 'Produk Tidak Dikenal',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (foodProduct.brands != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      foodProduct.brands!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (foodProduct.nutriscoreGrade != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getNutriscoreColor(
                          foodProduct.nutriscoreGrade!,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Nutriscore ${foodProduct.nutriscoreGrade!.toUpperCase()}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.fastfood, size: 40, color: Colors.grey.shade400),
    );
  }

  Widget _buildScoreCard(AnalysisResult analysis) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: analysis.isSafe ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              analysis.isSafe ? Icons.check_circle : Icons.warning,
              size: 60,
              color: analysis.isSafe ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              analysis.isSafe ? 'Aman Dikonsumsi' : 'Tidak Disarankan',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: analysis.isSafe
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor: ${analysis.overallScore.toStringAsFixed(0)}/100',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              analysis.scoreCategory,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningsCard(List<Warning> warnings) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Peringatan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...warnings.map((warning) => _buildWarningItem(warning)),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(Warning warning) {
    Color color;
    IconData icon;

    switch (warning.severity) {
      case WarningSeverity.high:
        color = Colors.red;
        icon = Icons.error;
        break;
      case WarningSeverity.medium:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case WarningSeverity.low:
        color = Colors.blue;
        icon = Icons.info;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  warning.message,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(List<String> recommendations) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Rekomendasi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(Nutriments nutriments) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Nutrisi (per 100g)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (nutriments.energyKcal != null)
              _buildNutrientRow(
                'Kalori',
                '${nutriments.energyKcal!.toStringAsFixed(0)} kcal',
              ),
            if (nutriments.proteins != null)
              _buildNutrientRow(
                'Protein',
                '${nutriments.proteins!.toStringAsFixed(1)} g',
              ),
            if (nutriments.carbohydrates != null)
              _buildNutrientRow(
                'Karbohidrat',
                '${nutriments.carbohydrates!.toStringAsFixed(1)} g',
              ),
            if (nutriments.sugars != null)
              _buildNutrientRow(
                '  - Gula',
                '${nutriments.sugars!.toStringAsFixed(1)} g',
              ),
            if (nutriments.fat != null)
              _buildNutrientRow(
                'Lemak',
                '${nutriments.fat!.toStringAsFixed(1)} g',
              ),
            if (nutriments.saturatedFat != null)
              _buildNutrientRow(
                '  - Lemak Jenuh',
                '${nutriments.saturatedFat!.toStringAsFixed(1)} g',
              ),
            if (nutriments.fiber != null)
              _buildNutrientRow(
                'Serat',
                '${nutriments.fiber!.toStringAsFixed(1)} g',
              ),
            if (nutriments.salt != null)
              _buildNutrientRow(
                'Garam',
                '${nutriments.salt!.toStringAsFixed(2)} g',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSummaryCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil Anda',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'BMI',
              '${userProfile.bmi.toStringAsFixed(1)} (${userProfile.bmiCategory})',
            ),
            _buildInfoRow(
              'Kebutuhan Kalori',
              '${userProfile.dailyCalorieNeeds.toStringAsFixed(0)} kcal/hari',
            ),
            _buildInfoRow('Tujuan', userProfile.goal),
            if (userProfile.medicalConditions.isNotEmpty)
              _buildInfoRow(
                'Riwayat Penyakit',
                userProfile.medicalConditions.join(', '),
              ),
            if (userProfile.allergies.isNotEmpty)
              _buildInfoRow('Alergi', userProfile.allergies.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNutriscoreColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return Colors.green.shade700;
      case 'b':
        return Colors.lightGreen.shade600;
      case 'c':
        return Colors.orange.shade600;
      case 'd':
        return Colors.deepOrange.shade600;
      case 'e':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}
