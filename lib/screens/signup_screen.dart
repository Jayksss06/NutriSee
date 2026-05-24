import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap setujui Terms & Condition')),
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pushNamed(context, '/otp');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Latar gelap untuk Desktop/Web
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480), // Batas maksimal UI
          child: Container(
            color: Colors.white, // Latar belakang utama area konten (putih)
            child: Stack(
              children: [
                // 1. Latar Belakang Pola (Bagian Atas)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.40,
                  child: Image.asset(
                    'assets/images/REGISTERBG.png', // Sesuaikan dengan nama aset background Sign Up Anda
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback jika gambar belum tersedia
                      return CustomPaint(
                        painter: SignupPatternPainter(),
                      );
                    },
                  ),
                ),

                // 3. Area Form Hijau dengan Kurva Cembung
                Positioned(
                  top: size.height * 0.28, // Menyesuaikan titik mulai kurva
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipPath(
                    clipper: TopCurveClipper(),
                    child: Container(
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                            top: 60, left: 24, right: 24, bottom: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo Kustom (menggunakan Aset)
                              _buildLogo(),
                              const SizedBox(height: 35),

                              // Input Nama Lengkap
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Nama Lengkap',
                                icon: Icons
                                    .email_outlined, // Mengikuti desain lampiran Anda yang menggunakan ikon amplop untuk nama (sebaiknya diganti Icons.person_outline jika itu typo di desain)
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Masukkan nama'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // Input Email
                              _buildTextField(
                                controller: _emailController,
                                hint: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Masukkan email';
                                  if (!v.contains('@'))
                                    return 'Email tidak valid';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Input Password
                              _buildTextField(
                                controller: _passwordController,
                                hint: 'Password',
                                icon: Icons.lock_outline,
                                obscure: _obscurePassword,
                                isPassword: true,
                                onTogglePassword: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Masukkan password';
                                  if (v.length < 6) return 'Min 6 karakter';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Input Konfirmasi Password
                              _buildTextField(
                                controller: _confirmPasswordController,
                                hint: 'Konfirmasi Password',
                                icon: Icons.lock_outline,
                                obscure: _obscureConfirm,
                                isPassword: true,
                                onTogglePassword: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                                validator: (v) {
                                  if (v != _passwordController.text) {
                                    return 'Password tidak cocok';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Checkbox Terms & Condition
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _agreeTerms,
                                      onChanged: (v) => setState(
                                          () => _agreeTerms = v ?? false),
                                      shape:
                                          const CircleBorder(), // Membuat checkbox berbentuk lingkaran
                                      checkColor: AppColors
                                          .primary, // Centang warna hijau
                                      fillColor:
                                          MaterialStateProperty.resolveWith(
                                        (states) => states.contains(
                                                MaterialState.selected)
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                      side: const BorderSide(
                                          color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Setuju Dengan ',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Terms & Condition',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // Tombol Sign Up
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5),
                                        )
                                      : Text(
                                          'SIGN UP',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            letterSpacing: 1.0,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Link Sign In
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Sudah Punya Akun? ',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Sign In',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Pemanggilan Aset Logo Kustom
  Widget _buildLogo() {
    return Image.asset(
      'assets/images/LOGO.png',
      height: 60,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Logo Asset Not Found',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  // Komponen Input Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isPassword = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: Colors.transparent, // Background transparan seperti Login
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF7070), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF7070), width: 1.5),
        ),
        errorStyle:
            GoogleFonts.inter(color: const Color(0xFFFFB3B3), fontSize: 11),
        hintStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}

// Pemotong Area Hijau untuk Membentuk Kurva Cembung
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 40);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 40);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Pelukis Latar Belakang (Pola Makanan Abstrak - Fallback)
class SignupPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final positions = [
      Offset(size.width * 0.15, size.height * 0.1),
      Offset(size.width * 0.85, size.height * 0.12),
      Offset(size.width * 0.3, size.height * 0.3),
      Offset(size.width * 0.75, size.height * 0.4),
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.6),
    ];

    for (var pos in positions) {
      canvas.drawCircle(pos, 25, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
