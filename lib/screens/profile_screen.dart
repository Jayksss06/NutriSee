import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar & name
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              user.name.isEmpty ? 'Pengguna' : user.name,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              user.email,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Stats cards
            Row(
              children: [
                Expanded(child: _statCard('BMI', user.bmi > 0 ? user.bmi.toStringAsFixed(1) : '-', user.bmiCategory)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Kalori/hari', '${user.targetCalories}', 'target')),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Target', '${user.targetWeight.toStringAsFixed(0)}kg', 'berat badan')),
              ],
            ),
            const SizedBox(height: 24),
            // Info card
            Container(
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
                children: [
                  _infoRow('Jenis Kelamin', user.gender),
                  const Divider(height: 24),
                  _infoRow('Umur', '${user.age} tahun'),
                  const Divider(height: 24),
                  _infoRow('Berat', '${user.weight.toStringAsFixed(0)} kg'),
                  const Divider(height: 24),
                  _infoRow('Tinggi', '${user.height.toStringAsFixed(0)} cm'),
                  const Divider(height: 24),
                  _infoRow('Target Berat', '${user.targetWeight.toStringAsFixed(0)} kg'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Settings
            Container(
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
                children: [
                  _settingsTile(Icons.edit_outlined, 'Edit Profil', onTap: () {
                    Navigator.pushNamed(context, '/profile-setup');
                  }),
                  const Divider(height: 1, indent: 56),
                  _settingsTile(Icons.notifications_outlined, 'Notifikasi'),
                  const Divider(height: 1, indent: 56),
                  _settingsTile(Icons.help_outline, 'Bantuan'),
                  const Divider(height: 1, indent: 56),
                  _settingsTile(
                    Icons.logout,
                    'Keluar',
                    color: AppColors.danger,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                            'Konfirmasi',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                          ),
                          content: Text(
                            'Apakah kamu ingin keluar?',
                            style: GoogleFonts.inter(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Batal', style: GoogleFonts.inter()),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                provider.logout();
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/login', (_) => false);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child: Text('Keluar', style: GoogleFonts.inter()),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String label,
      {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary, size: 22),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
      onTap: onTap,
      dense: true,
    );
  }
}
