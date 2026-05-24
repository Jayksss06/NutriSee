import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth/auth_provider.dart';   // ✅ fix: auth/ subfolder
import '../providers/nutrition_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/calorie_gauge_widget.dart';
import '../widgets/bmi_widget.dart';
import '../widgets/macro_card.dart';
import '../widgets/weight_tracker_widget.dart';
import '../widgets/nutrition_chart_widget.dart';
import 'profile_screen.dart';
import 'nutri_diary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _DashboardView(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-data'),
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

// ── DASHBOARD ─────────────────────────────────────────────
class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid != null) {
      context.read<NutritionProvider>().init(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final nutrition = context.watch<NutritionProvider>();
    final user = auth.userModel;

    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Header ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Hello,',
                      style: GoogleFonts.inter(
                          fontSize: 15, color: AppColors.textSecondary)),
                  Text(
                    user.name.isEmpty ? 'Pengguna' : user.name,
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                ]),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NutriDiaryScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      const Icon(Icons.menu_book_rounded,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text('Diary',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Stat chips ───────────────────────────────
            Row(children: [
              _statChip('Umur', '${user.age}th'),
              const SizedBox(width: 8),
              _statChip('Tinggi', '${user.height.toStringAsFixed(0)}cm'),
              const SizedBox(width: 8),
              _statChip('Berat', '${user.weight.toStringAsFixed(0)}kg'),
              const SizedBox(width: 8),
              _statChip('Target', '${user.targetWeight.toStringAsFixed(0)}kg'),
            ]),
            const SizedBox(height: 16),

            // ── Calorie Gauge ────────────────────────────
            CalorieGaugeWidget(
              targetCalories: user.targetCalories,
              caloriesEaten: nutrition.caloriesEaten,
              caloriesBurned: nutrition.caloriesBurned,
            ),
            const SizedBox(height: 12),

            // ── Macro Cards ──────────────────────────────
            Row(children: [
              Expanded(
                child: MacroCard(
                  label: 'Karbo',
                  current: nutrition.carbsToday.round(),
                  target: user.targetCarbs,
                  unit: 'g',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MacroCard(
                  label: 'Protein',
                  current: nutrition.proteinToday.round(),
                  target: user.targetProtein,
                  unit: 'g',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MacroCard(
                  label: 'Lemak',
                  current: nutrition.fatToday.round(),
                  target: user.targetFat,
                  unit: 'g',
                  color: AppColors.primary,
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // ── BMI ──────────────────────────────────────
            BmiWidget(bmi: user.bmi, category: user.bmiCategory),
            const SizedBox(height: 16),

            // ── Weight Tracker ───────────────────────────
            WeightTrackerWidget(weightHistory: nutrition.weightLogs),
            const SizedBox(height: 16),

            // ── Weekly Chart ─────────────────────────────
            NutritionChartWidget(weeklyData: nutrition.weeklyNutrition),
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
        child: Column(children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

// ── BOTTOM NAV ────────────────────────────────────────────
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
        child: Row(children: [
          Expanded(
            child: _NavItem(
              icon: Icons.home_rounded,
              label: 'Beranda',
              isSelected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          const Expanded(child: SizedBox()),
          Expanded(
            child: _NavItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              isSelected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
        ]),
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
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon,
              color: isSelected ? AppColors.primary : AppColors.textLight,
              size: 24),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }
}