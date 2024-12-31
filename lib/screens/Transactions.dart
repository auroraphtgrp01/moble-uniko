import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import 'package:intl/intl.dart';
import 'TransactionDetail.dart';
import 'package:uniko/screens/Chatbot.dart';
import 'package:uniko/widgets/FundSelector.dart';
import 'package:uniko/widgets/AddCategoryDrawer.dart';
import 'dart:ui';
import 'package:uniko/widgets/CategoryDrawer.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedCategory = 'Tất cả';
  String _selectedFund = 'Tất cả';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  FilterType? _filterType;

  final List<CategoryItem> _categories = [
    CategoryItem(emoji: '🌟', name: 'Tất cả', color: const Color(0xFF5856D6)),
    CategoryItem(emoji: '🍲', name: 'Ăn uống', color: const Color(0xFFFF6B6B)),
    CategoryItem(
        emoji: '🚌', name: 'Di chuyển', color: const Color(0xFF4DABF7)),
    CategoryItem(emoji: '🛒', name: 'Mua sắm', color: const Color(0xFFE599F7)),
    CategoryItem(emoji: '🏥', name: 'Sức khỏe', color: const Color(0xFF34C759)),
    CategoryItem(emoji: '🎬', name: 'Giải trí', color: const Color(0xFFFFB86C)),
    CategoryItem(emoji: '💰', name: 'Thu nhập', color: const Color(0xFF34C759)),
  ];

  Future<void> _onRefresh() async {
    // Giả lập loading trong 1.5 giây
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      // Thêm logic cập nhật dữ liệu ở đây
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.background.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.isDarkMode
                        ? Colors.white.withOpacity(0.03)
                        : Colors.black.withOpacity(0.03),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sổ giao dịch',
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
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: () => _showFilterDrawer(),
                ),
                FundSelector(
                  selectedFund: _selectedFund,
                  onFundChanged: (fund) => setState(() => _selectedFund = fund),
                ),
              ],
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.primary,
        backgroundColor: AppTheme.cardBackground,
        edgeOffset: MediaQuery.of(context).padding.top + 80,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(top: 120),
              sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : AppTheme.borderColor,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      label: 'Thu nhập',
                      amount: '15,300,000',
                      isIncome: true,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.divider,
                    ),
                    _buildSummaryItem(
                      label: 'Chi tiêu',
                      amount: '8,520,000',
                      isIncome: false,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category.name == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        avatar: Text(category.emoji),
                        label: Text(category.name),
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.white : AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                        backgroundColor: AppTheme.cardBackground,
                        selectedColor: category.color,
                        side: BorderSide(
                          color: isSelected
                              ? category.color
                              : AppTheme.isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : AppTheme.borderColor,
                          width: 0.5,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onSelected: (bool selected) {
                          setState(() => _selectedCategory = category.name);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildDateGroup(
                  date: 'Hôm nay',
                  transactions: [
                    _buildTransaction(
                      icon: Icons.restaurant,
                      title: 'Ăn trưa',
                      amount: '-45,000',
                      time: '12:30',
                      category: '🍲 Ăn uống',
                    ),
                    _buildTransaction(
                      icon: Icons.directions_bus,
                      title: 'Xe buýt',
                      amount: '-7,000',
                      time: '09:15',
                      category: '🚌 Di chuyển',
                    ),
                  ],
                ),
                _buildDateGroup(
                  date: 'Hôm qua',
                  transactions: [
                    _buildTransaction(
                      icon: Icons.work,
                      title: 'Lương tháng 3',
                      amount: '+15,300,000',
                      time: '10:00',
                      category: '💰 Thu nhập',
                      isIncome: true,
                    ),
                    _buildTransaction(
                      icon: Icons.shopping_bag,
                      title: 'Siêu thị',
                      amount: '-320,000',
                      time: '18:45',
                      category: '🛒 Mua sắm',
                    ),
                  ],
                ),
                _buildDateGroup(
                  date: '21/03/2024',
                  transactions: [
                    _buildTransaction(
                      icon: Icons.local_hospital,
                      title: 'Khám bệnh',
                      amount: '-850,000',
                      time: '14:20',
                      category: '🏥 Sức khỏe',
                    ),
                    _buildTransaction(
                      icon: Icons.movie,
                      title: 'Xem phim',
                      amount: '-150,000',
                      time: '20:30',
                      category: '🎬 Giải trí',
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "reload",
            onPressed: () {
              // TODO: Implement reload logic
            },
            backgroundColor: AppTheme.primary,
            child: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
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

  Widget _buildSummaryItem({
    required String label,
    required String amount,
    required bool isIncome,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$amount đ',
          style: TextStyle(
            color: isIncome ? const Color(0xFF34C759) : AppTheme.error,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDateGroup({
    required String date,
    required List<Widget> transactions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            date,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...transactions,
      ],
    );
  }

  void _showCategoryDrawer(BuildContext context, String currentCategory) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CategoryDrawer(
        currentCategory: currentCategory,
        categories: _categories,
        onCategorySelected: (category) {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildTransaction({
    required IconData icon,
    required String title,
    required String amount,
    required String time,
    required String category,
    bool isIncome = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailPage(
              icon: icon,
              title: title,
              amount: amount,
              date: time,
              category: category,
              isIncome: isIncome,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : AppTheme.borderColor,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isIncome
                    ? const Color(0xFF34C759).withOpacity(0.1)
                    : AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isIncome ? const Color(0xFF34C759) : AppTheme.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Content
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
                      InkWell(
                        onTap: () => _showCategoryDrawer(context, category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ],
                          ),
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
                        time,
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

            // Amount
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

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DateFilterDrawer(
        startDate: _filterStartDate,
        endDate: _filterEndDate,
        currentFilter: _filterType,
        onFilterChanged: (start, end, type) {
          setState(() {
            _filterStartDate = start;
            _filterEndDate = end;
            _filterType = type;
          });
          // TODO: Implement filter logic
        },
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

enum FilterType {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

class DateFilterDrawer extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final FilterType? currentFilter;
  final Function(DateTime? start, DateTime? end, FilterType type)
      onFilterChanged;

  const DateFilterDrawer({
    super.key,
    this.startDate,
    this.endDate,
    this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<DateFilterDrawer> createState() => _DateFilterDrawerState();
}

class _DateFilterDrawerState extends State<DateFilterDrawer> {
  late FilterType _selectedFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter ?? FilterType.all;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppTheme.isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Bộ lọc thời gian',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Đóng',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick Filters
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterOption(
                  FilterType.all,
                  'Tất cả',
                  'Hiển thị toàn bộ giao dịch',
                  Icons.all_inclusive_rounded,
                ),
                _buildFilterOption(
                  FilterType.today,
                  'Hôm nay',
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  Icons.today_rounded,
                ),
                _buildFilterOption(
                  FilterType.yesterday,
                  'Hôm qua',
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.now().subtract(const Duration(days: 1))),
                  Icons.history_rounded,
                ),
                _buildFilterOption(
                  FilterType.thisWeek,
                  'Tuần này',
                  'Từ thứ 2 đến chủ nhật',
                  Icons.view_week_rounded,
                ),
                _buildFilterOption(
                  FilterType.thisMonth,
                  'Tháng này',
                  DateFormat('MM/yyyy').format(DateTime.now()),
                  Icons.calendar_view_month_rounded,
                ),
                _buildFilterOption(
                  FilterType.lastMonth,
                  'Tháng trước',
                  DateFormat('MM/yyyy').format(
                    DateTime(DateTime.now().year, DateTime.now().month - 1),
                  ),
                  Icons.calendar_month_rounded,
                ),
                _buildFilterOption(
                  FilterType.thisYear,
                  'Năm nay',
                  DateFormat('yyyy').format(DateTime.now()),
                  Icons.calendar_today_rounded,
                ),
                _buildFilterOption(
                  FilterType.custom,
                  'Tùy chọn',
                  'Chọn khoảng thời gian',
                  Icons.date_range_rounded,
                ),
                if (_selectedFilter == FilterType.custom) ...[
                  const SizedBox(height: 16),
                  _buildCustomDateRange(),
                ],
              ],
            ),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                _updateDateRange();
                widget.onFilterChanged(_startDate, _endDate, _selectedFilter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    FilterType type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedFilter == type;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : AppTheme.borderColor,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.1)
                    : AppTheme.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDateRange() {
    return Row(
      children: [
        Expanded(
          child: _buildDateButton(
            'Từ ngày',
            _startDate,
            (date) => setState(() => _startDate = date),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateButton(
            'Đến ngày',
            _endDate,
            (date) => setState(() => _endDate = date),
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton(
    String label,
    DateTime? date,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selected != null) {
          onDateSelected(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('dd/MM/yyyy').format(date)
                  : 'Chọn ngày',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateDateRange() {
    switch (_selectedFilter) {
      case FilterType.all:
        _startDate = null;
        _endDate = null;
        break;
      case FilterType.today:
        _startDate = DateTime.now();
        _endDate = DateTime.now();
        break;
      case FilterType.yesterday:
        _startDate = DateTime.now().subtract(const Duration(days: 1));
        _endDate = DateTime.now().subtract(const Duration(days: 1));
        break;
      case FilterType.thisWeek:
        final now = DateTime.now();
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = _startDate!.add(const Duration(days: 6));
        break;
      case FilterType.thisMonth:
        final now = DateTime.now();
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case FilterType.lastMonth:
        final now = DateTime.now();
        _startDate = DateTime(now.year, now.month - 1, 1);
        _endDate = DateTime(now.year, now.month, 0);
        break;
      case FilterType.thisYear:
        final now = DateTime.now();
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
      case FilterType.custom:
        // Dates are already set through date pickers
        break;
    }
  }
}
