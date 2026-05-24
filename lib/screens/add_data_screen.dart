import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth/auth_provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/food_entry_model.dart';
import '../models/activity_model.dart';
import '../utils/app_theme.dart';
import 'scan_food_screen.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  // --- FOOD STATE ---
  final _namaMakananController = TextEditingController();
  String _kategoriMakan = 'Makan Siang';
  int _porsi = 1;
  FoodEntryModel? _estimatedFood;

  // --- ACTIVITY STATE ---
  final _namaAktivitasController = TextEditingController();
  int _durasi = 10;
  String _intensitas = 'Sedang';

  final List<String> _listMakan = ['Sarapan', 'Makan Siang', 'Makan Malam', 'Camilan'];
  final List<String> _listIntensitas = ['Ringan', 'Sedang', 'Berat'];

  @override
  void dispose() {
    _namaMakananController.dispose();
    _namaAktivitasController.dispose();
    super.dispose();
  }

  String _mealTypeToKey(String label) {
    switch (label) {
      case 'Sarapan': return 'breakfast';
      case 'Makan Siang': return 'lunch';
      case 'Makan Malam': return 'dinner';
      default: return 'snack';
    }
  }

  Future<void> _estimateFood() async {
    final name = _namaMakananController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nama makanan dulu')),
      );
      return;
    }
    final nutrition = context.read<NutritionProvider>();
    final result = await nutrition.estimateFoodWithAI(name, _mealTypeToKey(_kategoriMakan));
    if (!mounted) return;
    if (result != null) {
      setState(() => _estimatedFood = result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal estimasi, coba lagi')),
      );
    }
  }

  Future<void> _saveMakanan() async {
    if (_estimatedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estimasi kalori dulu sebelum simpan')),
      );
      return;
    }
    final nutrition = context.read<NutritionProvider>();
    final entry = FoodEntryModel(
      name: _estimatedFood!.name,
      category: _estimatedFood!.category,
      portion: _porsi,
      calories: (_estimatedFood!.calories * _porsi),
      carbs: _estimatedFood!.carbs * _porsi,
      protein: _estimatedFood!.protein * _porsi,
      fat: _estimatedFood!.fat * _porsi,
      mealType: _mealTypeToKey(_kategoriMakan),
      estimatedByAI: true,
    );
    await nutrition.addFood(entry);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Makanan berhasil dicatat ✓')),
    );
    Navigator.pop(context);
  }

  Future<void> _saveAktivitas() async {
    final name = _namaAktivitasController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nama aktivitas')),
      );
      return;
    }
    final nutrition = context.read<NutritionProvider>();
    final auth = context.read<AuthProvider>();
    final weight = auth.userModel?.weight ?? 70;
    final result = await nutrition.estimateActivityWithAI(name, _durasi, weight);
    if (!mounted) return;
    if (result != null) {
      await nutrition.addActivity(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas berhasil dicatat ✓')),
      );
      Navigator.pop(context);
    } else {
      // Fallback simpan tanpa AI
      await nutrition.addActivity(ActivityModel(
        name: name,
        intensity: _intensitas.toLowerCase(),
        duration: _durasi,
        caloriesBurned: _durasi * 7,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Tambah Data',
              style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20)),
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
            tabs: const [Tab(text: 'Makan'), Tab(text: 'Aktivitas')],
          ),
        ),
        body: TabBarView(
          children: [_buildMakanTab(), _buildAktivitasTab()],
        ),
      ),
    );
  }

  // ── TAB MAKAN ─────────────────────────────────────────
  Widget _buildMakanTab() {
    final nutrition = context.watch<NutritionProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input + Scan button
          _buildInputCard([
            _label('Nama Makanan'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _textField(_namaMakananController, 'Contoh: Nasi Goreng'),
                ),
                const SizedBox(width: 10),
                // Tombol Scan
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (_) => const ScanFoodScreen()),
                    );
                    if (result != null && result.isNotEmpty) {
                      _namaMakananController.text = result;
                      await _estimateFood();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _label('Kategori'),
            const SizedBox(height: 10),
            _buildChoiceRow(_listMakan, _kategoriMakan,
                (v) => setState(() => _kategoriMakan = v)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Porsi'),
                  Text('$_porsi Porsi',
                      style: GoogleFonts.inter(color: AppColors.textSecondary)),
                ]),
                _buildStepper(_porsi, (v) => setState(() => _porsi = v)),
              ],
            ),
          ]),
          const SizedBox(height: 12),

          // Tombol Estimasi AI
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: nutrition.isEstimating ? null : _estimateFood,
              icon: nutrition.isEstimating
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: Text(
                nutrition.isEstimating ? 'Mengestimasi...' : 'Estimasi Kalori dengan AI',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Hasil Estimasi
          if (_estimatedFood != null) ...[
            _buildResultCard(
              'Kalori Estimasi (×$_porsi porsi)',
              '${_estimatedFood!.calories * _porsi} kcal',
              Icons.bolt,
              Colors.amber,
            ),
            const SizedBox(height: 12),
            Row(children: [
              _buildSmallNutrisiCard(
                  'Karbohidrat', '${(_estimatedFood!.carbs * _porsi).toStringAsFixed(1)} g'),
              const SizedBox(width: 12),
              _buildSmallNutrisiCard(
                  'Protein', '${(_estimatedFood!.protein * _porsi).toStringAsFixed(1)} g'),
              const SizedBox(width: 12),
              _buildSmallNutrisiCard(
                  'Lemak', '${(_estimatedFood!.fat * _porsi).toStringAsFixed(1)} g'),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.auto_awesome, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Diestimasi oleh AI',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ],
          const SizedBox(height: 24),
          _btnSubmit('Simpan Makanan', nutrition.isEstimating ? null : _saveMakanan),
        ],
      ),
    );
  }

  // ── TAB AKTIVITAS ─────────────────────────────────────
  Widget _buildAktivitasTab() {
    final nutrition = context.watch<NutritionProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputCard([
            _label('Apa yang kamu lakukan?'),
            const SizedBox(height: 8),
            _textField(_namaAktivitasController, 'Contoh: Jogging'),
            const SizedBox(height: 20),
            _label('Intensitas'),
            const SizedBox(height: 10),
            _buildChoiceRow(_listIntensitas, _intensitas,
                (v) => setState(() => _intensitas = v)),
            const SizedBox(height: 20),
            _label('Durasi (Menit)'),
            const SizedBox(height: 10),
            Center(
              child: _buildStepper(_durasi, (v) => setState(() => _durasi = v),
                  isLarge: true),
            ),
          ]),
          const SizedBox(height: 15),
          _buildResultCard(
            'Estimasi Membakar',
            '~${_durasi * 7} kcal',
            Icons.local_fire_department,
            Colors.orange,
          ),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.auto_awesome, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('AI akan hitung ulang saat simpan',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 24),
          _btnSubmit('Simpan Aktivitas', nutrition.isEstimating ? null : _saveAktivitas),
        ],
      ),
    );
  }

  // ── WIDGETS HELPER ────────────────────────────────────
  Widget _label(String text) => Text(text,
      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14));

  Widget _textField(TextEditingController controller, String hint) {
    return Container(
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildChoiceRow(
      List<String> list, String selected, Function(String) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: list.map((item) {
        final isSelected = selected == item;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderColor)),
            child: Text(item,
                style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepper(int value, Function(int) onChange, {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperBtn(Icons.remove, () { if (value > 1) onChange(value - 1); }),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isLarge ? 24 : 16),
            child: Text(
              isLarge ? '$value Menit' : '$value',
              style: GoogleFonts.inter(
                  fontSize: isLarge ? 18 : 16, fontWeight: FontWeight.w700),
            ),
          ),
          _stepperBtn(Icons.add, () => onChange(value + 1)),
        ],
      ),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  Widget _buildResultCard(String title, String val, IconData icon, Color iconCol) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: iconCol, size: 22),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        Text(val,
            style: GoogleFonts.inter(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildSmallNutrisiCard(String title, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(val,
              style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _btnSubmit(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.borderColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}