import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class BmiWidget extends StatelessWidget {
  final double bmi;
  final String category;

  const BmiWidget({super.key, required this.bmi, required this.category});

  Color get _categoryColor {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return AppColors.obesitasColor;
  }

  double get _indicatorPosition {
    // Map BMI to 0-1 position on the bar
    // Bar goes from ~10 to ~40 BMI
    return ((bmi - 10) / 30).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BMI Kamu',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Text(
                    bmi > 0 ? bmi.toStringAsFixed(1) : '0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _categoryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // BMI gradient bar
          Stack(
            children: [
              // Gradient bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 12,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.orange,
                        Colors.red,
                      ],
                    ),
                  ),
                ),
              ),
              // Indicator
              if (bmi > 0)
                Positioned(
                  left: (MediaQuery.of(context).size.width - 80) *
                      _indicatorPosition,
                  top: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textPrimary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kurang',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: AppColors.textLight)),
              Text('Normal',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: AppColors.textLight)),
              Text('Lebih',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: AppColors.textLight)),
              Text('Obesitas',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}
