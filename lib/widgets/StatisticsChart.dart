import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartItemData {
  final String label;
  final String amount;
  final double percentage;
  final Color color;

  ChartItemData({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class StatisticsChart extends StatelessWidget {
  final bool isExpense;
  final List<ChartItemData> data;
  final VoidCallback onViewMore;

  const StatisticsChart({
    Key? key,
    required this.isExpense,
    required this.data,
    required this.onViewMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isExpense ? 'Chi tiêu theo danh mục' : 'Thu nhập theo danh mục',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isExpense ? Colors.red : const Color(0xFF34C759))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _calculateTotal(),
                  style: TextStyle(
                    color: isExpense ? Colors.red : const Color(0xFF34C759),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SfCircularChart(
            legend: Legend(
              isVisible: true,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            series: <CircularSeries>[
              DoughnutSeries<ChartItemData, String>(
                dataSource: data,
                xValueMapper: (ChartItemData item, _) => item.label,
                yValueMapper: (ChartItemData item, _) => item.percentage,
                pointColorMapper: (ChartItemData item, _) => item.color,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  showZeroValue: false,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                innerRadius: '60%',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.map((item) => _buildCompactLegendItem(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLegendItem(ChartItemData item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${item.percentage.round()}%',
            style: TextStyle(
              color: item.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotal() {
    double total = 0;
    for (var item in data) {
      total += item.percentage;
    }
    return '${total.round()}%';
  }
}
