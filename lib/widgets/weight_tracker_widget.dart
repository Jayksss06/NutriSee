import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';

class WeightTrackerWidget extends StatefulWidget {
  final List<WeightEntry> weightHistory;

  const WeightTrackerWidget({super.key, required this.weightHistory});

  @override
  State<WeightTrackerWidget> createState() => _WeightTrackerWidgetState();
}

class _WeightTrackerWidgetState extends State<WeightTrackerWidget> {
  int _selectedPeriod = 0;
  final List<String> _periods = ['Minggu', 'Bulan', '6 Bulan', '1 Tahun'];
  final List<String> _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  List<FlSpot> get _spots {
    if (widget.weightHistory.isEmpty) return [];
    return widget.weightHistory.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();
  }

  double get _minY {
    if (widget.weightHistory.isEmpty) return 80;
    return (widget.weightHistory.map((e) => e.weight).reduce(
              (a, b) => a < b ? a : b) -
          5)
        .floorToDouble();
  }

  double get _maxY {
    if (widget.weightHistory.isEmpty) return 115;
    return (widget.weightHistory.map((e) => e.weight).reduce(
              (a, b) => a > b ? a : b) +
          5)
        .ceilToDouble();
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pelacak Berat Badan',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Period tabs
          Row(
            children: _periods.asMap().entries.map((e) {
              final isSelected = e.key == _selectedPeriod;
              return GestureDetector(
                onTap: () => setState(() => _selectedPeriod = e.key),
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
                    style: GoogleFonts.poppins(
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
          const SizedBox(height: 16),
          // Chart
          SizedBox(
            height: 180,
            child: widget.weightHistory.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data berat badan',
                      style: GoogleFonts.poppins(
                        color: AppColors.textLight,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: _minY,
                      maxY: _maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.borderColor,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}kg',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= _days.length) {
                                return const SizedBox();
                              }
                              return Text(
                                _days[idx],
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppColors.textLight,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots,
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.08),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
