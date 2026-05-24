import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: Stack(
          children: [
            // Food icon pattern background
            Positioned.fill(
              child: CustomPaint(
                painter: FoodPatternPainter(),
              ),
            ),
            // Center content
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Nutri',
                              style: GoogleFonts.inter(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'see',
                              style: GoogleFonts.inter(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4ADE80),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pantau nutrisi harianmu',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Start button at bottom
          ],
        ),
      ),
    );
  }
}

class FoodPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw simple food icons as circles/shapes for the pattern
    final positions = [
      Offset(size.width * 0.1, size.height * 0.05),
      Offset(size.width * 0.85, size.height * 0.08),
      Offset(size.width * 0.25, size.height * 0.15),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.05, size.height * 0.3),
      Offset(size.width * 0.9, size.height * 0.35),
      Offset(size.width * 0.45, size.height * 0.08),
      Offset(size.width * 0.15, size.height * 0.55),
      Offset(size.width * 0.8, size.height * 0.55),
      Offset(size.width * 0.35, size.height * 0.7),
      Offset(size.width * 0.65, size.height * 0.75),
      Offset(size.width * 0.1, size.height * 0.85),
      Offset(size.width * 0.9, size.height * 0.85),
      Offset(size.width * 0.5, size.height * 0.92),
    ];

    final sizes = [
      20.0,
      15.0,
      25.0,
      18.0,
      22.0,
      16.0,
      20.0,
      18.0,
      24.0,
      20.0,
      16.0,
      22.0,
      18.0,
      20.0
    ];

    for (int i = 0; i < positions.length; i++) {
      // Draw circle (fruit/food)
      canvas.drawCircle(positions[i], sizes[i % sizes.length], paint);
      // Draw small square accent
      if (i % 3 == 0) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(positions[i].dx + 30, positions[i].dy + 20),
            width: 8,
            height: 8,
          ),
          paint..color = const Color(0xFF4ADE80).withOpacity(0.4),
        );
        paint.color = Colors.white.withOpacity(0.06);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
