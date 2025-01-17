import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:uniko/models/statistics.dart';
import 'package:uniko/providers/fund_provider.dart';
import 'package:uniko/widgets/TransactionDetailDrawer.dart';
import '../../config/theme.config.dart';
import '../SubScreen/TransactionDetail.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import '../../widgets/BalanceCard.dart';
import 'package:uniko/screens/ChatBot/Chatbot.dart';
import '../SubScreen/AccountDetail.dart';
import '../../widgets/CommonHeader.dart';
import 'package:provider/provider.dart';
import 'package:uniko/providers/statistics_provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../../widgets/StatisticsChart.dart';
import '../../widgets/ClassificationDrawer.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {
            _selectedIndex = _tabController.index;
          });
        }
      });
  }

  void _fetchStatisticsData() {
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, 1);
    final endDay = DateTime(now.year, now.month + 1, 0);

    final fundId = context.read<FundProvider>().selectedFundId;
    if (fundId != null) {
      context.read<StatisticsProvider>().fetchStatistics(
            fundId,
            startDay,
            endDay,
          );
    }
  }

  void _switchTab(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _tabController.animateTo(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      // Thêm logic cập nhật dữ liệu ở đây
    });
  }

  String _formatAmount(num amount, bool isExpense) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${isExpense ? "-" : "+"}${formatter.format(amount)} đ';
  }

  Widget _buildRecentTransactions() {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        final transactions =
            provider.statistics?.unclassifiedTransactions ?? [];

        if (transactions.isEmpty) {
          return Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : AppTheme.borderColor,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tất cả giao dịch đã được phân loại',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đã phân loại tất cả các giao dịch. Hãy tiếp tục duy trì thói quen tốt này nhé!',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giao dịch chưa phân loại',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${transactions.length} giao dịch',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...transactions.map((transaction) =>
                _buildUnclassifiedTransactionItem(transaction)),
          ],
        );
      },
    );
  }

  Widget _buildUnclassifiedTransactionItem(
      UnclassifiedTransaction transaction) {
    final isExpense = transaction.direction.toUpperCase() == 'EXPENSE';
    final amount = _formatAmount(transaction.amount, isExpense);

    // Chuyển đổi UTC sang UTC+7
    final localDateTime =
        transaction.transactionDateTime.add(const Duration(hours: 7));
    final date = DateFormat('HH:mm - dd/MM/yyyy').format(localDateTime);

    return GestureDetector(
      onTap: () => _showTransactionDetail(transaction),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            // Transaction Type Indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: isExpense ? AppTheme.error : const Color(0xFF34C759),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Account Info
                      Expanded(
                        child: Text(
                          transaction.toAccountNo ??
                              transaction.accountSource.name ??
                              "Không xác định",
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Amount
                      Text(
                        amount,
                        style: TextStyle(
                          color: isExpense
                              ? AppTheme.error
                              : const Color(0xFF34C759),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Date and Type
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isExpense
                                  ? AppTheme.error
                                  : const Color(0xFF34C759))
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isExpense ? 'Chi tiêu' : 'Thu nhập',
                          style: TextStyle(
                            color: isExpense
                                ? AppTheme.error
                                : const Color(0xFF34C759),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(UnclassifiedTransaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TransactionDetailDrawer(
        id: transaction.id,
        amount: _formatAmount(transaction.amount,
            transaction.direction.toUpperCase() == 'EXPENSE'),
        description: transaction.description,
        date: transaction.transactionDateTime,
        sourceAccount: transaction.accountSource.name,
        toAccountNo: transaction.toAccountNo,
        toAccountName: transaction.toAccountName,
        toBankName: transaction.toBankName,
        isIncome: transaction.direction.toUpperCase() != 'EXPENSE',
        onClassifyPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ClassificationDrawer(
              transactionId: transaction.id,
              onSave: (reason, category, description) {
                // TODO: Implement save logic
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: const CommonHeader(title: 'Tổng quan'),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.primary,
        backgroundColor: AppTheme.cardBackground,
        edgeOffset: MediaQuery.of(context).padding.top + 80,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 70),
              sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            // Header
            // Balance Card with Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _buildBalanceCard(),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: _buildStatsCards(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            // Chart Content
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : AppTheme.borderColor,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 400,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 500,
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            dragStartBehavior: DragStartBehavior.down,
                            children: [
                              _buildExpenseChart(),
                              _buildIncomeChart(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom),
            ),

            // Recent Transactions
            SliverToBoxAdapter(
              child: _buildRecentTransactions(),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "chatbot",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotScreen()),
              );
            },
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.chat_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChart() {
    return Consumer<StatisticsProvider>(builder: (context, provider, child) {
      final stats = provider.statistics;
      if (stats == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                'Chưa có thống kê chi tiêu nào',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      final data = stats.expenseTransactionTypeStats.map((stat) {
        final totalExpense = stats.expense.totalToday;
        final percentage = totalExpense > 0
            ? (stat.value / totalExpense * 100).roundToDouble()
            : 0.0;

        return ChartItemData(
          label: stat.name,
          amount: _formatAmount(stat.value, true),
          percentage: percentage,
          color: Color((Random().nextDouble() * 0xFFFFFF).toInt())
              .withOpacity(1.0),
        );
      }).toList();

      return StatisticsChart(
        isExpense: true,
        data: data,
        onViewMore: () => _showCategoriesDrawer(context, isExpense: true),
      );
    });
  }

  Widget _buildIncomeChart() {
    return Consumer<StatisticsProvider>(builder: (context, provider, child) {
      final stats = provider.statistics;
      if (stats == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                'Chưa có thống kê thu nhập nào',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      final data = stats.incomingTransactionTypeStats.map((stat) {
        final totalIncome = stats.income.totalToday;
        final percentage = totalIncome > 0
            ? (stat.value / totalIncome * 100).roundToDouble()
            : 0.0;

        return ChartItemData(
          label: stat.name,
          amount: _formatAmount(stat.value, false),
          percentage: percentage,
          color: Color((Random().nextDouble() * 0xFFFFFF).toInt())
              .withOpacity(1.0),
        );
      }).toList();

      return StatisticsChart(
        isExpense: false,
        data: data,
        onViewMore: () => _showCategoriesDrawer(context, isExpense: false),
      );
    });
  }

  void _showCategoriesDrawer(BuildContext context, {required bool isExpense}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.borderColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isExpense ? 'Danh mục chi tiêu' : 'Danh mục thu nhập',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (isExpense) ...[
                    _buildDrawerItem(
                        'Ăn uống',
                        '3,834,000',
                        const Color(0xFF4E73F8).withOpacity(0.9),
                        Icons.restaurant),
                    const SizedBox(height: 12),
                    _buildDrawerItem(
                        'Di chuyển',
                        '2,982,000',
                        const Color(0xFF00C48C).withOpacity(0.9),
                        Icons.directions_car),
                    const SizedBox(height: 12),
                    _buildDrawerItem(
                        'Mua sắm',
                        '850,000',
                        const Color(0xFFFFA26B).withOpacity(0.9),
                        Icons.shopping_bag),
                    const SizedBox(height: 12),
                    _buildDrawerItem('Giải trí', '520,000',
                        const Color(0xFFFF6B6B).withOpacity(0.9), Icons.movie),
                    const SizedBox(height: 12),
                    _buildDrawerItem(
                        'Sức khỏe',
                        '334,000',
                        const Color(0xFF34C759).withOpacity(0.9),
                        Icons.favorite),
                  ] else ...[
                    _buildDrawerItem('Lương', '12,240,000',
                        const Color(0xFF00C48C).withOpacity(0.9), Icons.work),
                    const SizedBox(height: 12),
                    _buildDrawerItem(
                        'Thưởng',
                        '2,500,000',
                        const Color(0xFF4E73F8).withOpacity(0.9),
                        Icons.card_giftcard),
                    const SizedBox(height: 12),
                    _buildDrawerItem(
                        'Đầu tư',
                        '560,000',
                        const Color(0xFFFFA26B).withOpacity(0.9),
                        Icons.trending_up),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      String label, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$amount đ',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String amount,
    required String date,
    required String category,
    bool isIncome = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailPage(
              icon: icon,
              title: title,
              amount: amount,
              date: date,
              category: category,
              isIncome: isIncome,
              id: '1',
            ),
          ),
        );
      },
      child: Container(
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
                color: isIncome ? const Color(0xFF34C759) : AppTheme.error,
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
                          fontSize: 11,
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
                color: isIncome ? const Color(0xFF34C759) : AppTheme.error,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$amount đ',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildBalanceCardSkeleton();
        }

        final balance = provider.statistics?.total.totalBalance ?? 0;
        final percentChange = provider.statistics?.total.rate ?? 0.0;
        final random = Random();
        final chartData = List.generate(
            7, (index) => FlSpot(index.toDouble(), random.nextDouble() * 100));

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AccountDetailPage()),
            );
          },
          child: BalanceCard(
            balance: (balance as num).toDouble(),
            percentChange: double.tryParse(
                    provider.statistics?.total.rate.toString() ?? '0') ??
                0.0,
            chartData: chartData,
          ),
        );
      },
    );
  }

  Widget _buildBalanceCardSkeleton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 180,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCardsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : AppTheme.borderColor,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : AppTheme.borderColor,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildStatsCards() {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildStatsCardsSkeleton();
        }

        final expense = provider.statistics?.income.totalToday ?? 0;
        final income = provider.statistics?.expense.totalToday ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Chi tiêu Card
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchTab(0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0
                          ? AppTheme.error.withOpacity(0.1)
                          : AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedIndex == 0
                            ? AppTheme.error
                            : AppTheme.isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : AppTheme.borderColor,
                        width: 1.5,
                      ),
                      boxShadow: _selectedIndex == 0
                          ? [
                              BoxShadow(
                                color: AppTheme.error.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_down,
                              color: _selectedIndex == 0
                                  ? AppTheme.error
                                  : AppTheme.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Chi tiêu',
                              style: TextStyle(
                                color: _selectedIndex == 0
                                    ? AppTheme.error
                                    : AppTheme.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${NumberFormat('#,###', 'vi_VN').format(expense)} đ',
                          style: TextStyle(
                            color: AppTheme.error,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Thu nhập Card
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchTab(1),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1
                          ? const Color(0xFF34C759).withOpacity(0.1)
                          : AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedIndex == 1
                            ? const Color(0xFF34C759)
                            : AppTheme.isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : AppTheme.borderColor,
                        width: 1.5,
                      ),
                      boxShadow: _selectedIndex == 1
                          ? [
                              BoxShadow(
                                color: const Color(0xFF34C759).withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: _selectedIndex == 1
                                  ? const Color(0xFF34C759)
                                  : AppTheme.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Thu nhập',
                              style: TextStyle(
                                color: _selectedIndex == 1
                                    ? const Color(0xFF34C759)
                                    : AppTheme.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${NumberFormat('#,###', 'vi_VN').format(income)} đ',
                          style: TextStyle(
                            color: const Color(0xFF34C759),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
