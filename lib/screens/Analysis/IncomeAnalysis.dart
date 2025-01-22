import 'package:flutter/material.dart';
import '../../config/theme.config.dart';
import 'package:intl/intl.dart';

class IncomeAnalysisScreen extends StatefulWidget {
  const IncomeAnalysisScreen({super.key});

  @override
  State<IncomeAnalysisScreen> createState() => _IncomeAnalysisScreenState();
}

class _IncomeAnalysisScreenState extends State<IncomeAnalysisScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      'title': '💰 Lương',
      'amount': 15000000,
      'percentage': 0.6,
      'color': const Color(0xFF00C48C),
      'icon': Icons.payments_outlined,
      'transactions': 1,
      'trend': 0.05,
    },
    {
      'title': '💎 Đầu tư',
      'amount': 5000000,
      'percentage': 0.2,
      'color': const Color(0xFF5856D6),
      'icon': Icons.trending_up_rounded,
      'transactions': 3,
      'trend': 0.15,
    },
    {
      'title': '🎁 Thưởng',
      'amount': 3000000,
      'percentage': 0.12,
      'color': const Color(0xFFFF9500),
      'icon': Icons.card_giftcard_rounded,
      'transactions': 2,
      'trend': -0.08,
    },
    {
      'title': '💵 Thu nhập phụ',
      'amount': 2000000,
      'percentage': 0.08,
      'color': const Color(0xFFAF52DE),
      'icon': Icons.monetization_on_outlined,
      'transactions': 4,
      'trend': 0.2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Phân tích thu nhập',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Overview Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : AppTheme.borderColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng thu nhập',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C48C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: const Color(0xFF00C48C),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+8.3%',
                              style: TextStyle(
                                color: const Color(0xFF00C48C),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '25,000,000',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'VND',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          title: 'Giao dịch',
                          value: '10',
                          icon: Icons.receipt_long_outlined,
                          color: const Color(0xFF00C48C),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.divider,
                      ),
                      Expanded(
                        child: _buildSummaryItem(
                          title: 'Nguồn thu',
                          value: '4',
                          icon: Icons.account_balance_wallet_outlined,
                          color: const Color(0xFF5856D6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Category Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nguồn thu nhập',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C48C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00C48C).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: const Color(0xFF00C48C),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tháng này',
                          style: TextStyle(
                            color: const Color(0xFF00C48C),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categories List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return _buildCategoryItem(category);
              },
              childCount: categories.length,
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : AppTheme.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: category['color'].withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['title'],
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${category['transactions']} giao dịch',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat('#,###').format(category['amount']) + '₫',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (category['trend'] >= 0
                              ? const Color(0xFF00C48C)
                              : const Color(0xFFFF6B6B))
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category['trend'] >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: category['trend'] >= 0
                              ? const Color(0xFF00C48C)
                              : const Color(0xFFFF6B6B),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(category['trend'] * 100).abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: category['trend'] >= 0
                                ? const Color(0xFF00C48C)
                                : const Color(0xFFFF6B6B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: category['percentage'],
              backgroundColor: category['color'].withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(category['color']),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
} 