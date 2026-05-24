import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class CalorieGaugeWidget extends StatelessWidget {
  final int targetCalories;
  final int caloriesEaten;
  final int caloriesBurned;

  const CalorieGaugeWidget({
    super.key,
    required this.targetCalories,
    required this.caloriesEaten,
    required this.caloriesBurned,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        targetCalories > 0 ? (caloriesEaten / targetCalories).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Kalori: ${targetCalories > 0 ? targetCalories : 1360} cal',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Eaten
              Column(
                children: [
                  const Text('🍎', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(
                    '$caloriesEaten',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Dimakan',
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              // Gauge
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: GaugePainter(progress: progress),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${targetCalories > 0 ? targetCalories - caloriesEaten : 1360}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Kalori',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Burned
              Column(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(
                    '$caloriesBurned',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Terbakar',
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress;

  GaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = pi * 0.75;
    const sweepAngle = pi * 1.5;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );

    // Tip indicator
    if (progress > 0) {
      final angle = startAngle + sweepAngle * progress;
      final tipPos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final tipPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(tipPos, 6, tipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
