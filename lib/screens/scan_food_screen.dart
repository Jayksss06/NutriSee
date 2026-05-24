import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class ScanFoodScreen extends StatefulWidget {
  const ScanFoodScreen({super.key});

  @override
  State<ScanFoodScreen> createState() => _ScanFoodScreenState();
}

class _ScanFoodScreenState extends State<ScanFoodScreen> {
  bool isScanned = false;
  String scannedResult = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (!isScanned) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  setState(() {
                    isScanned = true;
                    scannedResult =
                        barcodes.first.rawValue ?? "Makanan Terdeteksi";
                  });
                }
              }
            },
          ),

          // Tombol Kembali
          if (!isScanned)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),

          // Area Fokus Kamera
          if (!isScanned)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 4),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

          // Tampilan Hasil Scan
          if (isScanned)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 100),
                    const SizedBox(height: 20),
                    Text(
                      scannedResult,
                      style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() => isScanned = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text("Scan Lagi",
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 16)),
                    )
                  ],
                ),
              ),
            ),

          // Navigasi Bawah
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bottomButton(Icons.qr_code, "Scan Food", isActive: true),
                  _bottomButton(Icons.grid_3x3, "Barcode"),
                  _bottomButton(Icons.label_outline, "Food Label"),
                  _bottomButton(Icons.image, "Gallery"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton(IconData icon, String label, {bool isActive = false}) {
    return Column(
      children: [
        Icon(icon,
            size: 30,
            color: isActive ? AppColors.primary : AppColors.textLight),
        const SizedBox(height: 5),
        Text(label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ))
      ],
    );
  }
}
