import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import 'package:intl/intl.dart';
import 'TransactionDetail.dart';
import 'package:uniko/screens/Chatbot.dart';
import 'package:uniko/widgets/FundSelector.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedCategory = 'Tất cả';
  String _selectedFund = 'Tất cả';

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
                child: Row(
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
                    FundSelector(
                      selectedFund: _selectedFund,
                      onFundChanged: (fund) => setState(() => _selectedFund = fund),
                    ),
                  ],
                ),
              ),
            ),

            // Monthly Summary
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

            // Thêm Categories List sau Monthly Summary
            SliverToBoxAdapter(
              child: SizedBox(
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

            // Transactions List
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
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drawer Handle
              Container(
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

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Danh mục',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Add Category Button
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement add category
                      },
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      label: Text(
                        'Thêm mới',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tìm danh mục...',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // Recent Categories
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Gần đây',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Categories List
              SizedBox(
                height: 36,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final category = _categories[index + 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: category.name == currentCategory,
                        showCheckmark: false,
                        avatar: Text(category.emoji),
                        label: Text(category.name),
                        labelStyle: TextStyle(
                          color: category.name == currentCategory
                              ? Colors.white
                              : AppTheme.textPrimary,
                          fontSize: 13,
                        ),
                        backgroundColor: AppTheme.cardBackground,
                        selectedColor: category.color,
                        side: BorderSide(
                          color: category.name == currentCategory
                              ? category.color
                              : AppTheme.isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : AppTheme.borderColor,
                          width: 0.5,
                        ),
                        onSelected: (_) {
                          // TODO: Update category
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // All Categories
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tất c��� danh mục',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Categories Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category.name == currentCategory;

                    return InkWell(
                      onTap: () {
                        // TODO: Update category
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category.color.withOpacity(0.1)
                              : AppTheme.isDarkMode
                                  ? Colors.white.withOpacity(0.02)
                                  : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? category.color
                                : AppTheme.isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : AppTheme.borderColor,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: category.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                category.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected
                                    ? category.color
                                    : AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
}

// Thêm class CategoryItem
class CategoryItem {
  final String emoji;
  final String name;
  final Color color;

  CategoryItem({
    required this.emoji,
    required this.name,
    required this.color,
  });
}
