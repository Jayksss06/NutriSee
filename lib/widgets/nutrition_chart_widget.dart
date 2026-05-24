import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_theme.dart';

// weeklyData format: List<{ 'date': String, 'calories': int,
//                            'protein': double, 'carbs': double, 'fat': double }>
class NutritionChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> weeklyData;

  const NutritionChartWidget({super.key, required this.weeklyData});

  @override
  State<NutritionChartWidget> createState() => _NutritionChartWidgetState();
}

class _NutritionChartWidgetState extends State<NutritionChartWidget> {
  int _selectedWeek = 0;
  final List<String> _periods = [
    'Minggu ini',
    'Mgg lalu',
    '2 mgg lalu',
    '3 mgg lalu',
  ];

  int get _totalCalories =>
      widget.weeklyData.fold(0, (sum, d) => sum + (d['calories'] as int? ?? 0));

  int get _avgCalories {
    if (widget.weeklyData.isEmpty) return 0;
    return (_totalCalories / widget.weeklyData.length).round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrisi',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Period tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _periods.asMap().entries.map((e) {
                final isSelected = e.key == _selectedWeek;
                return GestureDetector(
                  onTap: () => setState(() => _selectedWeek = e.key),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      e.value,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$_totalCalories',
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text('Total Kalori',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('$_avgCalories',
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text('Rerata Harian',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          // Bar chart
          SizedBox(
            height: 180,
            child: widget.weeklyData.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data nutrisi',
                      style:
                          GoogleFonts.inter(color: AppColors.textLight),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: widget.weeklyData
                              .map((d) =>
                                  (d['calories'] as int? ?? 0).toDouble())
                              .reduce((a, b) => a > b ? a : b) *
                          1.3,
                      barGroups:
                          widget.weeklyData.asMap().entries.map((e) {
                        final d = e.value;
                        final cal =
                            (d['calories'] as int? ?? 0).toDouble();
                        // ✅ safe cast dengan fallback 0.0
                        final protein =
                            (d['protein'] as num?)?.toDouble() ?? 0.0;
                        final carbs =
                            (d['carbs'] as num?)?.toDouble() ?? 0.0;
                        final fat =
                            (d['fat'] as num?)?.toDouble() ?? 0.0;

                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: cal,
                              color: AppColors.textPrimary,
                              width: 14,
                              borderRadius: BorderRadius.circular(4),
                              rodStackItems: [
                                BarChartRodStackItem(
                                    0, protein, AppColors.proteinColor),
                                BarChartRodStackItem(protein,
                                    protein + carbs, AppColors.karboColor),
                                BarChartRodStackItem(
                                    protein + carbs,
                                    protein + carbs + fat,
                                    AppColors.lemakColor),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                'S', 'S', 'R', 'K', 'J', 'S', 'M'
                              ];
                              final idx = value.toInt();
                              return Text(
                                idx < days.length ? days[idx] : '',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) =>
                            const FlLine(
                          color: AppColors.borderColor,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(Colors.black87, 'Kalori'),
              const SizedBox(width: 16),
              _legendItem(AppColors.proteinColor, 'Protein'),
              const SizedBox(width: 16),
              _legendItem(AppColors.karboColor, 'Karbo'),
              const SizedBox(width: 16),
              _legendItem(AppColors.lemakColor, 'Lemak'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}