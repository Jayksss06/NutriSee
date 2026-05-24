import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/calorie_gauge_widget.dart';
import '../widgets/bmi_widget.dart';
import '../widgets/macro_card.dart';
import '../widgets/weight_tracker_widget.dart';
import '../widgets/nutrition_chart_widget.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body:
          _selectedIndex == 0 ? const _DashboardView() : const ProfileScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mengubah dari showModalBottomSheet ke navigasi rute formal
          Navigator.pushNamed(context, '/add-data');
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Hello,',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              user.name.isEmpty ? 'Pengguna' : user.name,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statChip('Umur', '${user.age}th'),
                const SizedBox(width: 8),
                _statChip('Tinggi', '${user.height.toStringAsFixed(0)}cm'),
                const SizedBox(width: 8),
                _statChip('Berat', '${user.weight.toStringAsFixed(0)}kg'),
                const SizedBox(width: 8),
                _statChip(
                    'Target', '${user.targetWeight.toStringAsFixed(0)}kg'),
              ],
            ),
            const SizedBox(height: 16),
            CalorieGaugeWidget(
              targetCalories: user.targetCalories,
              caloriesEaten: provider.caloriesEaten,
              caloriesBurned: provider.caloriesBurned,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MacroCard(
                    label: 'Karbo',
                    current: provider.carbsToday.round(),
                    target: user.targetCarbs,
                    unit: 'g',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MacroCard(
                    label: 'Protein',
                    current: provider.proteinToday.round(),
                    target: user.targetProtein,
                    unit: 'g',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MacroCard(
                    label: 'Lemak',
                    current: provider.fatToday.round(),
                    target: user.targetFat,
                    unit: 'g',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BmiWidget(bmi: user.bmi, category: user.bmiCategory),
            const SizedBox(height: 16),
            WeightTrackerWidget(weightHistory: provider.weightHistory),
            const SizedBox(height: 16),
            NutritionChartWidget(weeklyData: provider.weeklyNutrition),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          // Menghapus CrossAxisAlignment.stretch untuk menghindari konflik layout
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
            ),
            const Expanded(child: SizedBox()), // Ruang kosong untuk FAB
            Expanded(
              child: _NavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height:
            double.infinity, // Memaksa area sentuh memenuhi tinggi BottomAppBar
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isSelected ? AppColors.primary : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
