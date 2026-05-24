import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  // --- STATE TAB MAKAN ---
  final _namaMakananController = TextEditingController();
  int porsi = 1;
  String kategoriMakan = "Makan Siang";
  final List<String> listMakan = [
    "Sarapan",
    "Makan Siang",
    "Makan Malam",
    "Camilan"
  ];

  // --- STATE TAB AKTIVITAS ---
  final _namaAktivitasController = TextEditingController();
  int durasi = 10;
  String intensitas = "Rendah";
  final List<String> listIntensitas = ["Rendah", "Sedang", "Tinggi"];

  @override
  void dispose() {
    _namaMakananController.dispose();
    _namaAktivitasController.dispose();
    super.dispose();
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
          title: Text(
            "Tambah Data",
            style: GoogleFonts.inter(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            labelStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
            tabs: const [
              Tab(text: "Makan"),
              Tab(text: "Aktivitas"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMakanTab(),
            _buildAktivitasTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMakanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInputCard([
            _label("Nama Makanan"),
            // PERBAIKAN: Menambahkan controller
            _textField(_namaMakananController, "Contoh: Ayam Bakar"),
            const SizedBox(height: 20),
            _label("Kategori"),
            const SizedBox(height: 10),
            _buildChoiceRow(listMakan, kategoriMakan,
                (val) => setState(() => kategoriMakan = val)),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Porsi"),
                    Text("$porsi Porsi",
                        style:
                            GoogleFonts.inter(color: AppColors.textSecondary)),
                  ],
                ),
                _buildStepper(porsi, (v) => setState(() => porsi = v)),
              ],
            ),
          ]),
          const SizedBox(height: 15),
          // Note: Di aplikasi nyata, nilai ini dihitung dinamis dari API/Database berdasarkan nama makanan
          _buildResultCard("Kalori Estimasi", "${450 * porsi} kcal", Icons.bolt,
              Colors.yellow),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildSmallNutrisiCard("Karbohidrat", "${42 * porsi} g"),
              const SizedBox(width: 15),
              _buildSmallNutrisiCard("Protein", "${18 * porsi} g"),
            ],
          ),
          const SizedBox(height: 25),

          // PERBAIKAN: Melempar fungsi onPressed spesifik untuk Makanan
          _btnSubmit("Simpan Makanan", () async {
            FocusManager.instance.primaryFocus?.unfocus();
            if (_namaMakananController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama makanan wajib diisi')));
              return;
            }

            // Eksekusi CRUD Insert melalui Provider
            context.read<AppProvider>().addFoodData(
                  _namaMakananController.text,
                  kategoriMakan,
                  porsi,
                  450 * porsi, // Estimasi kalori
                  42.0 * porsi, // Estimasi karbo
                  18.0 * porsi, // Estimasi protein
                  8.0 * porsi, // Estimasi lemak
                );

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Makanan berhasil dicatat')));
            await Future.delayed(const Duration(milliseconds: 150));
            if (mounted) {
              Navigator.pop(context);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildAktivitasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInputCard([
            _label("Apa yang kamu lakukan?"),
            // PERBAIKAN: Menambahkan controller
            _textField(_namaAktivitasController, "Contoh: Jogging"),
            const SizedBox(height: 20),
            _label("Intensitas"),
            const SizedBox(height: 10),
            _buildChoiceRow(listIntensitas, intensitas,
                (val) => setState(() => intensitas = val)),
            const SizedBox(height: 25),
            _label("Durasi (Menit)"),
            const SizedBox(height: 10),
            Center(
                child: _buildStepper(durasi, (v) => setState(() => durasi = v),
                    isLarge: true)),
          ]),
          const SizedBox(height: 15),
          // Note: Di aplikasi nyata, nilai ini dihitung dinamis (durasi * faktor intensitas)
          _buildResultCard("Estimasi Membakar", "${(durasi * 8)} kcal",
              Icons.local_fire_department, Colors.orange),
          const SizedBox(height: 25),

          // PERBAIKAN: Melempar fungsi onPressed spesifik untuk Aktivitas
          _btnSubmit("Simpan Aktivitas", () async {
            FocusManager.instance.primaryFocus?.unfocus();
            if (_namaAktivitasController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama aktivitas wajib diisi')));
              return;
            }

            // Eksekusi CRUD Insert melalui Provider
            context.read<AppProvider>().addActivityData(
                  _namaAktivitasController.text,
                  intensitas,
                  durasi,
                  durasi * 8, // Estimasi kalori dibakar
                );

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aktivitas berhasil dicatat')));
            await Future.delayed(const Duration(milliseconds: 150));
            if (mounted) {
              Navigator.pop(context);
            }
          }),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14));

  // PERBAIKAN: Tambah parameter controller
  Widget _textField(TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildChoiceRow(
      List<String> list, String selected, Function(String) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: list.map((item) {
        bool isSelected = selected == item;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderColor)),
            child: Text(item,
                style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepper(int value, Function(int) onChange,
      {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperBtn(Icons.remove, () {
            if (value > 1) onChange(value - 1);
          }),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isLarge ? 24 : 16),
            child: Text(
              isLarge ? "$value Menit" : "$value",
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

  Widget _buildResultCard(
      String title, String val, IconData icon, Color iconCol) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconCol, size: 24),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(val,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSmallNutrisiCard(String title, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(val,
                style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _btnSubmit(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}
