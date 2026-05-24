import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _searchController = TextEditingController();
  String _selectedMeal = 'lunch';
  FoodEntry? _selectedFood;

  // Simple food database
  final List<Map<String, dynamic>> _foodDatabase = [
    {'name': 'Nasi Putih (1 piring)', 'calories': 400, 'carbs': 80.0, 'protein': 8.0, 'fat': 1.0},
    {'name': 'Nasi Merah (1 piring)', 'calories': 350, 'carbs': 72.0, 'protein': 7.0, 'fat': 2.0},
    {'name': 'Ayam Bakar (1 potong)', 'calories': 200, 'carbs': 2.0, 'protein': 30.0, 'fat': 8.0},
    {'name': 'Ayam Goreng (1 potong)', 'calories': 320, 'carbs': 12.0, 'protein': 28.0, 'fat': 18.0},
    {'name': 'Ikan Salmon (150g)', 'calories': 280, 'carbs': 0.0, 'protein': 35.0, 'fat': 15.0},
    {'name': 'Telur Rebus (1 butir)', 'calories': 78, 'carbs': 0.6, 'protein': 6.0, 'fat': 5.0},
    {'name': 'Sayur Bayam (1 mangkuk)', 'calories': 41, 'carbs': 6.0, 'protein': 4.0, 'fat': 0.5},
    {'name': 'Tempe Goreng (1 potong)', 'calories': 160, 'carbs': 9.0, 'protein': 12.0, 'fat': 8.0},
    {'name': 'Tahu Goreng (1 potong)', 'calories': 80, 'carbs': 2.0, 'protein': 7.0, 'fat': 5.0},
    {'name': 'Pisang (1 buah)', 'calories': 89, 'carbs': 23.0, 'protein': 1.0, 'fat': 0.0},
    {'name': 'Apel (1 buah)', 'calories': 95, 'carbs': 25.0, 'protein': 0.5, 'fat': 0.0},
    {'name': 'Susu Sapi (250ml)', 'calories': 152, 'carbs': 12.0, 'protein': 8.0, 'fat': 8.0},
    {'name': 'Roti Tawar (2 lembar)', 'calories': 132, 'carbs': 26.0, 'protein': 5.0, 'fat': 2.0},
    {'name': 'Mie Goreng (1 piring)', 'calories': 520, 'carbs': 70.0, 'protein': 12.0, 'fat': 20.0},
    {'name': 'Gado-gado (1 piring)', 'calories': 380, 'carbs': 35.0, 'protein': 16.0, 'fat': 20.0},
    {'name': 'Teh Manis (1 gelas)', 'calories': 90, 'carbs': 22.0, 'protein': 0.0, 'fat': 0.0},
    {'name': 'Jus Jeruk (1 gelas)', 'calories': 112, 'carbs': 26.0, 'protein': 2.0, 'fat': 0.0},
  ];

  List<Map<String, dynamic>> get _filteredFoods {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _foodDatabase;
    return _foodDatabase.where((f) {
      return (f['name'] as String).toLowerCase().contains(q);
    }).toList();
  }

  void _addFood() {
    if (_selectedFood == null) return;
    context.read<AppProvider>().addFoodEntry(_selectedFood!);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedFood!.name} berhasil ditambahkan!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Makanan',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Meal type tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _mealTab('breakfast', 'Sarapan', '☀️'),
                      const SizedBox(width: 8),
                      _mealTab('lunch', 'Makan Siang', '🍽️'),
                      const SizedBox(width: 8),
                      _mealTab('dinner', 'Makan Malam', '🌙'),
                      const SizedBox(width: 8),
                      _mealTab('snack', 'Camilan', '🍎'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Search
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari makanan...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: GoogleFonts.inter(color: AppColors.textLight),
                  ),
                ),
              ],
            ),
          ),
          // Food list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredFoods.length,
              itemBuilder: (context, i) {
                final food = _filteredFoods[i];
                final isSelected = _selectedFood?.name == food['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFood = FoodEntry(
                        name: food['name'],
                        calories: food['calories'],
                        carbs: food['carbs'],
                        protein: food['protein'],
                        fat: food['fat'],
                        time: DateTime.now(),
                        mealType: _selectedMeal,
                      );
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.08)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food['name'],
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'K: ${food['carbs']}g  P: ${food['protein']}g  L: ${food['fat']}g',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${food['calories']} kal',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Add button
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 12,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedFood != null ? _addFood : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.borderColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Tambahkan',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mealTab(String value, String label, String emoji) {
    final isSelected = _selectedMeal == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMeal = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$emoji $label',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
