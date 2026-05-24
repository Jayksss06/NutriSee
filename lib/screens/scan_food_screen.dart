import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../utils/app_theme.dart';

class ScanFoodScreen extends StatefulWidget {
  const ScanFoodScreen({super.key});

  @override
  State<ScanFoodScreen> createState() => _ScanFoodScreenState();
}

class _ScanFoodScreenState extends State<ScanFoodScreen> {
  bool _isScanned = false;
  bool _isAnalyzing = false;
  String _scannedCode = '';
  Map<String, dynamic>? _foodResult;
  String? _errorMsg;

  Future<void> _analyzeWithAI(String barcode) async {
    setState(() {
      _isScanned = true;
      _isAnalyzing = true;
      _errorMsg = null;
      _foodResult = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'YOUR_CLAUDE_API_KEY',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 400,
          'messages': [
            {
              'role': 'user',
              'content': '''Barcode produk makanan terdeteksi: "$barcode".
Berikan estimasi produk makanan Indonesia yang mungkin memiliki barcode ini, atau jika tidak diketahui, berikan estimasi makanan umum.
Balas HANYA dengan JSON berikut tanpa teks lain:
{
  "name": "<nama produk>",
  "brand": "<merek jika ada, kosong jika tidak>",
  "calories": <int per sajian>,
  "carbs": <float gram>,
  "protein": <float gram>,
  "fat": <float gram>,
  "portion": <int gram per sajian>,
  "category": "<kategori>"
}'''
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['content'][0]['text'] as String;
        final clean = text.replaceAll(RegExp(r'```json|```'), '').trim();
        setState(() {
          _foodResult = jsonDecode(clean);
          _isAnalyzing = false;
        });
      } else {
        setState(() {
          _errorMsg = 'Gagal menganalisis. Coba scan ulang.';
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Koneksi bermasalah.';
        _isAnalyzing = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _isScanned = false;
      _isAnalyzing = false;
      _scannedCode = '';
      _foodResult = null;
      _errorMsg = null;
    });
  }

  void _confirmFood() {
    if (_foodResult == null) return;
    // Kirim nama makanan kembali ke AddDataScreen
    Navigator.pop(context, _foodResult!['name'] as String);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Kamera
          if (!_isScanned)
            MobileScanner(
              onDetect: (capture) {
                if (!_isScanned && capture.barcodes.isNotEmpty) {
                  final code = capture.barcodes.first.rawValue ?? '';
                  if (code.isNotEmpty) {
                    _scannedCode = code;
                    _analyzeWithAI(code);
                  }
                }
              },
            ),

          // Tombol back + overlay saat scan
          if (!_isScanned) ...[
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black45, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Scan Makanan',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Arahkan kamera ke barcode makanan',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ],

          // Hasil Scan + AI
          if (_isScanned)
            Container(
              color: Colors.black87,
              child: SafeArea(
                child: Column(children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      GestureDetector(
                        onTap: _reset,
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text('Hasil Analisis',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),

                  Expanded(
                    child: _isAnalyzing
                        ? _buildAnalyzing()
                        : _errorMsg != null
                            ? _buildError()
                            : _buildResult(),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
        const SizedBox(height: 20),
        Text('AI sedang menganalisis makanan...',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Text('Kode: $_scannedCode',
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
      ]),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
        const SizedBox(height: 16),
        Text(_errorMsg!,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _reset,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text('Scan Ulang',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _buildResult() {
    final f = _foodResult!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Card hasil
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.food_bank, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f['name'] ?? '-',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  if ((f['brand'] ?? '').toString().isNotEmpty)
                    Text(f['brand'],
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textSecondary)),
                ]),
              ),
            ]),
            const SizedBox(height: 20),
            // Kalori besar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt, color: Colors.amber, size: 22),
                    const SizedBox(width: 6),
                    Text('${f['calories']} kkal',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800)),
                    Text(' / ${f['portion']}g',
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 14)),
                  ]),
            ),
            const SizedBox(height: 16),
            // Makro
            Row(children: [
              _macroChip('Karbo', '${f['carbs']}g', Colors.blue.shade100),
              const SizedBox(width: 10),
              _macroChip('Protein', '${f['protein']}g', Colors.green.shade100),
              const SizedBox(width: 10),
              _macroChip('Lemak', '${f['fat']}g', Colors.orange.shade100),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.auto_awesome, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Dianalisis oleh AI · ${f['category']}',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ]),
        ),
        const Spacer(),
        // Tombol aksi
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('Scan Ulang',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _confirmFood,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('Gunakan Data Ini',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _macroChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}