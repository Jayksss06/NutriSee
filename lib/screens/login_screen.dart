import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final isComplete = auth.isProfileComplete;
      Navigator.pushReplacementNamed(
        context,
        isComplete ? '/home' : '/profile-setup',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Login gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        // 1. Ubah warna latar belakang utama menjadi gelap untuk area di luar batas mobile (Desktop/Web)
        backgroundColor: const Color(0xFF1E1E1E),
        body: IgnorePointer(
          ignoring: _isLoading,
          child: Center(
            child: ConstrainedBox(
              // 2. Batasi lebar maksimal menjadi 480px (standar UI mobile)
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                color: Colors.white, // Background layar mobile
                child: Stack(
                  children: [
                    // 1. Latar Belakang Pola (Doodle) Area Atas
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: size.height * 0.55,
                      child: CustomPaint(
                        painter: LoginPatternPainter(),
                      ),
                    ),

                    // 3. Gambar Model Perempuan (Hero Image)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/images/LOGINBG.png',
                          height: 0.55 * size.height,
                          width: double
                              .infinity, // 3. Pastikan gambar mengisi penuh batas kontainer
                          fit: BoxFit
                              .cover, // 4. Ubah dari contain menjadi cover agar tidak ada ruang kosong di pinggir
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: size.height * 0.35,
                              alignment: Alignment.center,
                              child: Icon(Icons.image_not_supported,
                                  size: 80,
                                  color: AppColors.primary.withAlpha((0.3 * 255).round())),
                            );
                          },
                        ),
                      ),
                    ),

                    // 4. Area Form Hijau dengan Kurva Cembung di Atasnya
                    Positioned(
                      top: size.height * 0.45,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipPath(
                        clipper: TopCurveClipper(),
                        child: Container(
                          color: AppColors.primary,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(
                                top: 70, left: 24, right: 24, bottom: 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Logo Nutrisee
                                  _buildLogo(),
                                  const SizedBox(height: 40),

                                  // Input Email
                                  _buildTextField(
                                    controller: _emailController,
                                    hintText: 'Email',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Masukkan email'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Input Password
                                  _buildTextField(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    icon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    isPassword: true,
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Masukkan password'
                                        : null,
                                    onTogglePassword: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),

                                  // Lupa Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Lupa Password?',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Tombol Sign In
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                              'SIGN IN',
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                letterSpacing: 1.0,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // Link Sign Up
                                  GestureDetector(
                                    onTap: () =>
                                        Navigator.pushNamed(context, '/signup'),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Belum Punya Akun? ',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Sign Up',
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
        ));
  }

  // Komponen Logo Kustom
// Komponen Logo menggunakan Aset Gambar
  Widget _buildLogo() {
    return Image.asset(
      'assets/images/LOGO.png', // Sesuaikan dengan nama file asli logo Anda
      height: 60, // Sesuaikan nilai ini agar proporsional dengan desain
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback visual jika path gambar salah atau belum di-load
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
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: Colors
            .transparent, // Menggunakan background transparan sesuai desain
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
    // Memulai dari kiri bawah batas tinggi kurva
    path.moveTo(0, 40);
    // Membuat kurva yang melengkung ke atas (y: 0) tepat di tengah layar
    path.quadraticBezierTo(size.width / 2, 0, size.width, 40);
    // Melanjutkan garis ke sudut kanan bawah layar
    path.lineTo(size.width, size.height);
    // Melanjutkan garis ke sudut kiri bawah layar
    path.lineTo(0, size.height);
    // Menutup path kembali ke titik mulai
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Pelukis Latar Belakang (Pola Makanan Abstrak)
class LoginPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withAlpha((0.08 * 255).round())
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Lingkaran placeholder untuk mensimulasikan pola pola makanan di latar belakang.
    // Jika Anda memiliki file SVG/gambar pola, Anda dapat menghapus kelas ini
    // dan membungkus scaffold dengan widget DecorationImage.
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
