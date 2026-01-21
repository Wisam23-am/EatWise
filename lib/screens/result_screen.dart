import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/food_product.dart';
import '../services/food_analyzer.dart';
import '../providers/user_provider.dart';
import 'barcode_scanner_screen.dart';

class ResultScreen extends StatefulWidget {
  final FoodProduct foodProduct;

  const ResultScreen({super.key, required this.foodProduct});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late AnalysisResult analysis;
  late UserProfile userProfile;

  @override
  void initState() {
    super.initState();
    // Ambil data profil dari Provider
    userProfile = Provider.of<UserProvider>(
      context,
      listen: false,
    ).userProfile!;

    // Jalankan analisis cerdas
    analysis = FoodAnalyzer.analyzeFoodSuitability(
      userProfile,
      widget.foodProduct,
    );

    // Haptic Feedback saat hasil muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (analysis.isSafe) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna tema berdasarkan hasil (Merah/Kuning/Hijau)
    final themeColor = _getThemeColor(analysis.trafficLight);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hasil Analisis',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BarcodeScannerScreen(),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. KARTU PRODUK (Hero Animation)
          _buildProductCard(),
          const SizedBox(height: 16),

          // 2. SKOR UTAMA (Traffic Light)
          _buildScoreCard(themeColor),
          const SizedBox(height: 20),

          // 3. PROFIL USER (Dikembalikan Lengkap dengan Desain Baru)
          Text("KONTEKS PENGGUNA", style: _headerStyle()),
          const SizedBox(height: 8),
          _buildUserStatsSection(),
          const SizedBox(height: 20),

          // 4. PERINGATAN (Warnings)
          if (analysis.warnings.isNotEmpty) ...[
            Text("PERINGATAN", style: _headerStyle()),
            const SizedBox(height: 8),
            _buildWarningsCard(analysis.warnings),
            const SizedBox(height: 20),
          ],

          // 5. REKOMENDASI (Recommendations)
          // Selalu tampilkan header jika ada isinya
          if (analysis.recommendations.isNotEmpty) ...[
            Text("REKOMENDASI", style: _headerStyle()),
            const SizedBox(height: 8),
            _buildRecommendationsCard(analysis.recommendations),
            const SizedBox(height: 20),
          ],

          // 6. INFO NUTRISI
          Text("DETAIL NUTRISI", style: _headerStyle()),
          const SizedBox(height: 8),
          if (widget.foodProduct.nutriments != null)
            _buildNutritionCard(widget.foodProduct.nutriments!)
          else
            const Text("Data nutrisi tidak tersedia lengkap."),

          const SizedBox(height: 30),

          // TOMBOL SCAN LAGI
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const BarcodeScannerScreen(),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(
                'Scan Produk Lain',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- STYLE HELPERS ---

  Color _getThemeColor(TrafficLight light) {
    switch (light) {
      case TrafficLight.green:
        return Colors.teal.shade700;
      case TrafficLight.yellow:
        return Colors.orange.shade800;
      case TrafficLight.red:
        return Colors.red.shade700;
    }
  }

  TextStyle _headerStyle() {
    return GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade600,
      letterSpacing: 1.2,
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProductCard() {
    // Fallback nama produk
    String displayName =
        widget.foodProduct.productName ??
        widget.foodProduct.brands ??
        'Produk Tanpa Nama';
    if (displayName.trim().isEmpty)
      displayName = 'Barcode: ${widget.foodProduct.barcode}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Hero Image
            Hero(
              tag: widget.foodProduct.barcode.isNotEmpty
                  ? widget.foodProduct.barcode
                  : 'product_img',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                  image: widget.foodProduct.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.foodProduct.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.foodProduct.imageUrl == null
                    ? Icon(Icons.fastfood, color: Colors.grey.shade400)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (widget.foodProduct.brands != null)
                    Text(
                      widget.foodProduct.brands!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
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

  Widget _buildScoreCard(Color color) {
    String title;
    IconData icon;

    switch (analysis.trafficLight) {
      case TrafficLight.green:
        title = "Aman Dikonsumsi";
        icon = Icons.verified_user_rounded;
        break;
      case TrafficLight.yellow:
        title = "Konsumsi Terbatas";
        icon = Icons.warning_amber_rounded;
        break;
      case TrafficLight.red:
        title = "Tidak Disarankan";
        icon = Icons.dangerous_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Skor Kecocokan: ${analysis.overallScore.toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // --- BAGIAN INI MENGEMBALIKAN DATA LAMA DENGAN TAMPILAN BARU ---
  Widget _buildUserStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Statistik Angka (BMI & Kalori)
          Row(
            children: [
              Expanded(
                child: _userStatItem(
                  label: "BMI",
                  value: userProfile.bmi.toStringAsFixed(1),
                  subValue: userProfile.bmiCategory, // e.g., "Normal"
                  icon: Icons.monitor_weight_outlined,
                  color: Colors.blue,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _userStatItem(
                  label: "Keb. Kalori",
                  value: "${userProfile.dailyCalorieNeeds.toStringAsFixed(0)}",
                  subValue: "kkal/hari",
                  icon: Icons.local_fire_department_outlined,
                  color: Colors.orange,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _userStatItem(
                  label: "Tujuan",
                  value: userProfile.goal,
                  subValue: userProfile.activityLevel,
                  icon: Icons.flag_outlined,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Baris 2: Tags (Penyakit & Alergi)
          Text(
            "Kondisi Kesehatan:",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (userProfile.medicalConditions.isEmpty &&
                  userProfile.allergies.isEmpty)
                _chipItem("Sehat / Tanpa Pantangan", Colors.grey),

              ...userProfile.medicalConditions.map(
                (e) => _chipItem(e, Colors.red),
              ),
              ...userProfile.allergies.map(
                (e) => _chipItem("Alergi $e", Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userStatItem({
    required String label,
    required String value,
    required String subValue,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          subValue,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _chipItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildWarningsCard(List<Warning> warnings) {
    return Column(
      children: warnings
          .map(
            (w) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: w.severity == WarningSeverity.high
                      ? Colors.red.shade300
                      : Colors.orange.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    w.severity == WarningSeverity.high
                        ? Icons.cancel
                        : Icons.warning_amber,
                    color: w.severity == WarningSeverity.high
                        ? Colors.red
                        : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          w.message,
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
            ),
          )
          .toList(),
    );
  }

  Widget _buildRecommendationsCard(List<String> recs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: recs
            .map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildNutritionCard(Nutriments n) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            "Informasi Nilai Gizi",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            "Per 100g sajian",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  _nutriRow(
                    "Energi",
                    "${n.energyKcal?.toStringAsFixed(0) ?? '-'} kkal",
                  ),
                  _nutriRow(
                    "Lemak Total",
                    "${n.fat?.toStringAsFixed(1) ?? '-'} g",
                  ),
                  _nutriRow(
                    "Lemak Jenuh",
                    "${n.saturatedFat?.toStringAsFixed(1) ?? '-'} g",
                  ),
                  _nutriRow(
                    "Karbohidrat",
                    "${n.carbohydrates?.toStringAsFixed(1) ?? '-'} g",
                  ),
                  _nutriRow("Gula", "${n.sugars?.toStringAsFixed(1) ?? '-'} g"),
                  _nutriRow(
                    "Protein",
                    "${n.proteins?.toStringAsFixed(1) ?? '-'} g",
                  ),
                  _nutriRow("Garam", "${n.salt?.toStringAsFixed(2) ?? '-'} g"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutriRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          Text(
            val,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
