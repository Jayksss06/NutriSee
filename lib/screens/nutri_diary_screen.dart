import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth/auth_provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/food_entry_model.dart';
import '../models/activity_model.dart';
import '../utils/app_theme.dart';

class NutriDiaryScreen extends StatefulWidget {
  const NutriDiaryScreen({super.key});

  @override
  State<NutriDiaryScreen> createState() => _NutriDiaryScreenState();
}

class _NutriDiaryScreenState extends State<NutriDiaryScreen> {
  // 7 hari ke belakang, index 6 = hari ini
  late final List<DateTime> _week;
  int _selectedIndex = 6;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _week = List.generate(
        7, (i) => DateTime(now.year, now.month, now.day - (6 - i)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid != null) {
      final nutrition = context.read<NutritionProvider>();
      nutrition.init(uid);
      nutrition.changeDate(_week[_selectedIndex]);
    }
  }

  void _onDayTap(int index) {
    setState(() => _selectedIndex = index);
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid != null) {
      context.read<NutritionProvider>().changeDate(_week[index]);
    }
  }

  String _dayLabel(DateTime date) {
    return DateFormat('E', 'id_ID').format(date).toUpperCase().substring(0, 3);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();
    final user = context.watch<AuthProvider>().userModel;
    final selectedDate = _week[_selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Nutri Diary',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(children: [
        // ── Calendar Strip ────────────────────────────
        _buildCalendarStrip(),

        // ── Content ───────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total kalori card
              _buildTotalKaloriCard(nutrition, user?.targetCalories ?? 2000),
              const SizedBox(height: 20),

              // Label tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Makan & Aktivitas',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  Text(
                    _isToday(selectedDate)
                        ? 'Hari ini'
                        : DateFormat('d MMM', 'id_ID').format(selectedDate),
                    style: GoogleFonts.inter(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Food entries
              if (nutrition.foodEntries.isEmpty &&
                  nutrition.activities.isEmpty)
                _buildEmpty()
              else ...[
                if (nutrition.foodEntries.isNotEmpty) ...[
                  _sectionLabel('🍽️ Makanan'),
                  const SizedBox(height: 8),
                  ...nutrition.foodEntries.map((e) => _buildFoodItem(e, nutrition)),
                  const SizedBox(height: 16),
                ],
                if (nutrition.activities.isNotEmpty) ...[
                  _sectionLabel('🏃 Aktivitas'),
                  const SizedBox(height: 8),
                  ...nutrition.activities.map((a) => _buildActivityItem(a, nutrition)),
                ],
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Calendar Strip ────────────────────────────────────
  Widget _buildCalendarStrip() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(bottom: 16, top: 4, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final date = _week[i];
          final isSelected = _selectedIndex == i;
          return GestureDetector(
            onTap: () => _onDayTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    width: 1),
              ),
              child: Column(children: [
                Text(
                  _dayLabel(date),
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day}',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : Colors.white),
                ),
                // Dot kalau hari ini
                if (_isToday(date))
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ]),
            ),
          );
        }),
      ),
    );
  }

  // ── Total Kalori Card ─────────────────────────────────
  Widget _buildTotalKaloriCard(NutritionProvider nutrition, int target) {
    final net = nutrition.caloriesEaten - nutrition.caloriesBurned;
    final progress = (net / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Total Kalori Bersih',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('$net kkal',
            style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.background,
            color: progress > 0.9 ? Colors.orange : AppColors.primary,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text('$net dari $target kkal target',
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 16),

        Row(children: [
          Expanded(
              child: _subInfo('Dikonsumsi',
                  '${nutrition.caloriesEaten}', Icons.restaurant_menu)),
          Expanded(
              child: _subInfo('Dibakar',
                  '${nutrition.caloriesBurned}', Icons.local_fire_department)),
          Expanded(
              child: _subInfo('Protein',
                  '${nutrition.proteinToday.toStringAsFixed(0)}g', Icons.egg_outlined)),
        ]),
      ]),
    );
  }

  Widget _subInfo(String label, String value, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Row(children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 4),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ]),
    ]);
  }

  // ── Section Label ─────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary));
  }

  // ── Food Item ─────────────────────────────────────────
  Widget _buildFoodItem(FoodEntryModel entry, NutritionProvider nutrition) {
    final mealIcon = _mealIcon(entry.mealType);
    return Dismissible(
      key: Key(entry.id ?? entry.name),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        if (entry.id != null) nutrition.deleteFood(entry.id!);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(mealIcon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.name,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(
                '${_mealLabel(entry.mealType)} · '
                'K:${entry.carbs.toStringAsFixed(0)}g '
                'P:${entry.protein.toStringAsFixed(0)}g '
                'L:${entry.fat.toStringAsFixed(0)}g',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('+${entry.calories} kkal',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            if (entry.estimatedByAI)
              Row(children: [
                const Icon(Icons.auto_awesome,
                    size: 10, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                Text('AI',
                    style: GoogleFonts.inter(
                        fontSize: 10, color: AppColors.textSecondary)),
              ]),
          ]),
        ]),
      ),
    );
  }

  // ── Activity Item ─────────────────────────────────────
  Widget _buildActivityItem(ActivityModel activity, NutritionProvider nutrition) {
    return Dismissible(
      key: Key(activity.id ?? activity.name),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        if (activity.id != null) nutrition.deleteActivity(activity.id!);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.directions_run,
                color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(activity.name,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(
                '${activity.duration} menit · ${activity.intensity}',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ]),
          ),
          Text('-${activity.caloriesBurned} kkal',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange)),
        ]),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Icon(Icons.no_meals_outlined,
              size: 56, color: AppColors.textLight.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text('Belum ada catatan',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('Tap + untuk tambah makan atau aktivitas',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────
  IconData _mealIcon(String type) {
    switch (type) {
      case 'breakfast': return Icons.wb_sunny_outlined;
      case 'lunch': return Icons.restaurant;
      case 'dinner': return Icons.nightlight_outlined;
      default: return Icons.coffee_outlined;
    }
  }

  String _mealLabel(String type) {
    switch (type) {
      case 'breakfast': return 'Sarapan';
      case 'lunch': return 'Makan Siang';
      case 'dinner': return 'Makan Malam';
      default: return 'Camilan';
    }
  }
}