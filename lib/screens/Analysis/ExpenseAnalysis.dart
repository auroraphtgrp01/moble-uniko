import 'package:flutter/material.dart';
import 'package:uniko/screens/Analysis/IncomeAnalysis.dart';
import '../../config/theme.config.dart';
import 'package:intl/intl.dart';

class ExpenseAnalysisScreen extends StatefulWidget {
  const ExpenseAnalysisScreen({super.key});

  @override
  State<ExpenseAnalysisScreen> createState() => _ExpenseAnalysisScreenState();
}

class _ExpenseAnalysisScreenState extends State<ExpenseAnalysisScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      'title': '🍔 Ăn uống',
      'amount': 3500000,
      'percentage': 0.3,
      'color': const Color(0xFF4E73F8),
      'icon': Icons.restaurant_rounded,
      'transactions': 45,
      'trend': 0.12,
    },
    {
      'title': '🚗 Di chuyển',
      'amount': 2000000,
      'percentage': 0.2,
      'color': const Color(0xFF00C48C),
      'icon': Icons.directions_car_rounded,
      'transactions': 32,
      'trend': -0.05,
    },
    // ... thêm các category khác
  ];

  // Thêm dữ liệu cho phân tích thu nhập
  final List<Map<String, dynamic>> incomeCategories = [
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
          'Phân tích tài chính',
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
          // Thu nhập Overview
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C48C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: const Color(0xFF00C48C),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Thu nhập',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const IncomeAnalysisScreen(),
                            ),
                          );
                        },
                        child: Container(
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
                              Text(
                                'Xem chi tiết',
                                style: TextStyle(
                                  color: const Color(0xFF00C48C),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: const Color(0xFF00C48C),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '25,000,000₫',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 24,
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
                              color: const Color(0xFF00C48C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
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
                      Row(
                        children: [
                          _buildIncomeStat(
                            'Giao dịch',
                            '10',
                            Icons.receipt_long_outlined,
                          ),
                          const SizedBox(width: 20),
                          _buildIncomeStat(
                            'Nguồn thu',
                            '4',
                            Icons.account_balance_wallet_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Top 2 income sources
                  ...incomeCategories.map((category) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildIncomeItem(category),
                      )),
                ],
              ),
            ),
          ),

          // Chi tiêu Overview (existing code)
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
                        'Tổng chi tiêu',
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
                              '+12.5%',
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
                        '9,500,000',
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
                          value: '156',
                          icon: Icons.receipt_long_outlined,
                          color: AppTheme.primary,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.divider,
                      ),
                      Expanded(
                        child: _buildSummaryItem(
                          title: 'Danh mục',
                          value: '8',
                          icon: Icons.category_outlined,
                          color: const Color(0xFF00C48C),
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
                    'Danh mục chi tiêu',
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
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tháng này',
                          style: TextStyle(
                            color: AppTheme.primary,
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

  Widget _buildIncomeStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00C48C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF00C48C),
            size: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeItem(Map<String, dynamic> category) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: category['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            category['icon'],
            color: category['color'],
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category['title'],
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: category['percentage'],
                  backgroundColor: category['color'].withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(category['color']),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          NumberFormat('#,###').format(category['amount']) + '₫',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
} 