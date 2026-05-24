import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth/auth_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  String _gender = 'Laki-laki';
  DateTime? _birthDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill nama dari auth jika sudah ada
    final user = context.read<AuthProvider>().userModel;
    if (user != null) _nameController.text = user.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  String get _birthDateStr {
    if (_birthDate == null) return 'Pilih Tanggal';
    return '${_birthDate!.day.toString().padLeft(2, '0')}-'
        '${_birthDate!.month.toString().padLeft(2, '0')}-'
        '${_birthDate!.year}';
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.primary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _birthDate = date);
  }

  void _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan nama lengkap')));
      return;
    }
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal lahir')));
      return;
    }

    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final uid = auth.firebaseUser!.uid;
    final email = auth.firebaseUser!.email ?? '';

    final user = UserModel(
      uid: uid,
      email: email,
      name: _nameController.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      weight: double.tryParse(_weightController.text) ?? 0,
      height: double.tryParse(_heightController.text) ?? 0,
      targetWeight: double.tryParse(_targetWeightController.text) ?? 0,
    );

    final success = await auth.updateProfile(user);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error ?? 'Gagal menyimpan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text('Lengkapi Profil',
                  style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              Text('Supaya target kalorimu akurat',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 40),

              _buildFieldColumn(
                  label: 'Nama Lengkap',
                  child: _buildTextField(
                      controller: _nameController, hint: 'Nama kamu')),
              const SizedBox(height: 20),

              Row(children: [
                Expanded(
                    child: _buildFieldColumn(
                        label: 'Jenis Kelamin',
                        child: _buildDropdown())),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildFieldColumn(
                        label: 'Tanggal Lahir',
                        child: _buildDateField())),
              ]),
              const SizedBox(height: 20),

              Row(children: [
                Expanded(
                    child: _buildFieldColumn(
                        label: 'Berat (kg)',
                        child: _buildTextField(
                            controller: _weightController,
                            hint: '70',
                            keyboardType: TextInputType.number))),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildFieldColumn(
                        label: 'Tinggi (cm)',
                        child: _buildTextField(
                            controller: _heightController,
                            hint: '165',
                            keyboardType: TextInputType.number))),
              ]),
              const SizedBox(height: 20),

              _buildFieldColumn(
                  label: 'Target Berat (kg)',
                  child: _buildTextField(
                      controller: _targetWeightController,
                      hint: '60',
                      keyboardType: TextInputType.number)),
              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5)
                      : Text('Simpan & Mulai',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldColumn({required String label, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600)),
      const SizedBox(height: 8),
      child,
    ]);
  }

  BoxDecoration _box() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: _box(),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: _box(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _gender,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
          onChanged: (v) => setState(() => _gender = v ?? 'Laki-laki'),
          items: ['Laki-laki', 'Perempuan']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: _box(),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(_birthDateStr,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _birthDate == null
                            ? Colors.grey.shade400
                            : AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.calendar_today,
                  color: AppColors.primary, size: 16),
            ]),
      ),
    );
  }
}