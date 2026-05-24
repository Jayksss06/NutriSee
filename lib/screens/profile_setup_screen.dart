import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController(text: '110');
  final _heightController = TextEditingController(text: '170');
  final _targetWeightController = TextEditingController(text: '80');
  String _gender = 'Laki-laki';
  DateTime? _birthDate;
  bool _isSaving = false;

  // State untuk menangani gambar profil
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String get _birthDateStr {
    if (_birthDate == null) return '00-00-0000';
    return '${_birthDate!.day.toString().padLeft(2, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.year}';
  }

  // Fungsi mengambil gambar dari galeri
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengakses galeri gambar')),
        );
      }
    }
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _birthDate = date);
    }
  }

  void _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nama lengkap')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      final user = UserModel(
        name: _nameController.text,
        gender: _gender,
        birthDate: _birthDate ?? DateTime(2000),
        weight: double.tryParse(_weightController.text) ?? 70,
        height: double.tryParse(_heightController.text) ?? 165,
        targetWeight: double.tryParse(_targetWeightController.text) ?? 60,
      );

      context.read<AppProvider>().updateUser(user);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Latar gelap untuk Desktop/Web
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            // Warna latar belakang hijau sangat muda sesuai desain
            color: const Color(0xFFF1F6F2),
            height: double.infinity,
            child: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Judul Lengkapi Profil
                    Text(
                      'Lengkapi Profil',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Avatar Kustom
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: _imageFile != null
                                  ? Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey.shade400,
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 5,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Input Nama Lengkap
                    _buildFieldColumn(
                      label: 'Nama',
                      child: _buildTextField(
                        controller: _nameController,
                        hint: 'Nama Lengkap',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Baris 1: Jenis Kelamin & Tanggal Lahir
                    Row(
                      children: [
                        Expanded(
                          child: _buildFieldColumn(
                            label: 'Jenis Kelamin',
                            child: _buildDropdownField(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFieldColumn(
                            label: 'Tanggal Lahir',
                            child: _buildDateField(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Baris 2: Berat & Tinggi
                    Row(
                      children: [
                        Expanded(
                          child: _buildFieldColumn(
                            label: 'Berat',
                            child: _buildTextField(
                              controller: _weightController,
                              hint: '0',
                              suffix: 'kg',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFieldColumn(
                            label: 'Tinggi',
                            child: _buildTextField(
                              controller: _heightController,
                              hint: '0',
                              suffix: 'cm',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Input Target Berat
                    _buildFieldColumn(
                      label: 'Target Berat',
                      child: _buildTextField(
                        controller: _targetWeightController,
                        hint: '0',
                        suffix: 'kg',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Simpan',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Pembuat Layout Kolom (Label di luar box)
  Widget _buildFieldColumn({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // Desain dasar kotak putih
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200, width: 1.0),
    );
  }

  // Text Field Standar
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: _boxDecoration(),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
          suffixText: suffix,
          suffixStyle: GoogleFonts.inter(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // Dropdown Field Khusus
  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: _boxDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _gender,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          onChanged: (v) => setState(() => _gender = v ?? 'Laki-laki'),
          items: ['Laki-laki', 'Perempuan']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
        ),
      ),
    );
  }

  // Date Field Khusus
  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: _boxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                _birthDateStr,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
