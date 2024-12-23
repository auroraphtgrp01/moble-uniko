import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import 'package:intl/intl.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng quan',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tháng ${DateFormat('MM/yyyy').format(DateTime.now())}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Balance Card
            SliverToBoxAdapter(
              child: _buildBalanceCard(),
            ),

            // Stats Grid
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildListDelegate([
                  _buildStatCard(
                    title: 'Chi tiêu',
                    amount: '8,520,000',
                    trend: -12.5,
                    icon: Icons.trending_down,
                    iconColor: AppTheme.error,
                    gradientColors: [
                      const Color(0xFFFF6B6B),
                      const Color(0xFFFF8787),
                    ],
                  ),
                  _buildStatCard(
                    title: 'Thu nhập',
                    amount: '15,300,000',
                    trend: 8.3,
                    icon: Icons.trending_up,
                    iconColor: const Color(0xFF34C759),
                    gradientColors: [
                      const Color(0xFF34C759),
                      const Color(0xFF69DB7C),
                    ],
                  ),
                  _buildStatCard(
                    title: 'Tiết kiệm',
                    amount: '6,780,000',
                    trend: 15.7,
                    icon: Icons.savings_outlined,
                    iconColor: const Color(0xFF4DABF7),
                    gradientColors: [
                      const Color(0xFF4DABF7),
                      const Color(0xFF74C0FC),
                    ],
                  ),
                  _buildStatCard(
                    title: 'Đầu tư',
                    amount: '25,450,000',
                    trend: -5.2,
                    icon: Icons.insert_chart_outlined,
                    iconColor: const Color(0xFFE599F7),
                    gradientColors: [
                      const Color(0xFFE599F7),
                      const Color(0xFFEEBEFA),
                    ],
                  ),
                ]),
              ),
            ),

            // Recent Transactions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Giao dịch gần đây',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Xem tất cả',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTransactionItem(
                      icon: Icons.restaurant,
                      title: 'Ăn trưa',
                      amount: '-45,000',
                      date: 'Hôm nay, 12:30',
                      category: '�� Ăn uống',
                    ),
                    _buildTransactionItem(
                      icon: Icons.directions_bus,
                      title: 'Xe buýt',
                      amount: '-7,000',
                      date: 'Hôm nay, 09:15',
                      category: '🚌 Di chuyển',
                    ),
                    _buildTransactionItem(
                      icon: Icons.work,
                      title: 'Lương tháng 3',
                      amount: '+15,300,000',
                      date: 'Hôm qua, 10:00',
                      category: '💰 Thu nhập',
                      isIncome: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Số dư khả dụng',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '32,450,000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'VND',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+5.2%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceDetail(
                label: 'Thu nhập T3',
                value: '15.3M',
                trend: '+12.3%',
              ),
              _buildBalanceDetail(
                label: 'Chi tiêu T3',
                value: '8.5M',
                trend: '-8.1%',
              ),
              _buildBalanceDetail(
                label: 'Tiết kiệm',
                value: '6.8M',
                trend: '+4.5%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail({
    required String label,
    required String value,
    required String trend,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          trend,
          style: TextStyle(
            color: trend.startsWith('+') 
                ? Colors.greenAccent 
                : Colors.redAccent,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String amount,
    required double trend,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.isDarkMode 
              ? Colors.white.withOpacity(0.05)
              : AppTheme.borderColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$amount đ',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                trend >= 0 ? Icons.trending_up : Icons.trending_down,
                color: trend >= 0 
                    ? const Color(0xFF34C759)
                    : AppTheme.error,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${trend >= 0 ? '+' : ''}$trend%',
                style: TextStyle(
                  color: trend >= 0 
                      ? const Color(0xFF34C759)
                      : AppTheme.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String amount,
    required String date,
    required String category,
    bool isIncome = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.isDarkMode 
              ? Colors.white.withOpacity(0.05)
              : AppTheme.borderColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIncome 
                  ? const Color(0xFF34C759).withOpacity(0.1)
                  : AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isIncome 
                  ? const Color(0xFF34C759)
                  : AppTheme.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      date,
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
          Text(
            '$amount đ',
            style: TextStyle(
              color: isIncome 
                  ? const Color(0xFF34C759)
                  : AppTheme.error,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 