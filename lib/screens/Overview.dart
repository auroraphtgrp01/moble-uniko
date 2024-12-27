import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'TransactionDetail.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import '../widgets/BalanceCard.dart';
import 'package:uniko/screens/Chatbot.dart';
import 'package:uniko/widgets/FundSelector.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String _selectedFund = 'Tất cả';

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
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                    FundSelector(
                      selectedFund: _selectedFund,
                      onFundChanged: (fund) =>
                          setState(() => _selectedFund = fund),
                    ),
                  ],
                ),
              ),
            ),

            // Balance Card with Chart
            SliverToBoxAdapter(
              child: _buildBalanceCard(),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
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
                                '8,520,000 đ',
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
                                      color: const Color(0xFF34C759)
                                          .withOpacity(0.1),
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
                                '15,300,000 đ',
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
              ),
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
                      height: 350,
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
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom),
            ),

            // Recent Transactions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 12),
                    _buildTransactionItem(
                      context: context,
                      icon: Icons.restaurant,
                      title: 'Ăn trưa',
                      amount: '-45,000',
                      date: 'Hôm nay, 12:30',
                      category: 'Ăn uống',
                    ),
                    _buildTransactionItem(
                      context: context,
                      icon: Icons.directions_bus,
                      title: 'Xe buýt',
                      amount: '-7,000',
                      date: 'Hôm nay, 09:15',
                      category: '🚌 Di chuyển',
                    ),
                    _buildTransactionItem(
                      context: context,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: 45,
                    title: '45%',
                    color: const Color(0xFF4E73F8),
                    radius: 45,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5),
                  ),
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: const Color(0xFF00C48C),
                    radius: 45,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: const Color(0xFFFFA26B),
                    radius: 45,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildCompactLegendItem(
                  'Ăn uống',
                  '3,834,000',
                  const Color(0xFF4E73F8),
                  '45%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactLegendItem(
                  'Di chuyển',
                  '2,982,000',
                  const Color(0xFF00C48C),
                  '35%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _showCategoriesDrawer(context, isExpense: true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Xem thêm danh mục khác',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLegendItem(
      String label, String amount, Color color, String percentage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$amount đ',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: 80,
                    title: '80%',
                    color: const Color(0xFF00C48C),
                    radius: 45,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: const Color(0xFF4E73F8),
                    radius: 45,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildCompactLegendItem(
                  'Lương',
                  '12,240,000',
                  const Color(0xFF00C48C),
                  '80%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactLegendItem(
                  'Thưởng',
                  '3,060,000',
                  const Color(0xFF4E73F8),
                  '20%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _showCategoriesDrawer(context, isExpense: false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Xem thêm danh mục khác',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoriesDrawer(BuildContext context, {required bool isExpense}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
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
    return BalanceCard(
      balance: 67802200,
      percentChange: 12.5,
      chartData: const [
        FlSpot(0, 120),
        FlSpot(1, 130),
        FlSpot(2, 125),
        FlSpot(3, 140),
        FlSpot(4, 135),
        FlSpot(5, 150),
        FlSpot(6, 145),
      ],
    );
  }
}
