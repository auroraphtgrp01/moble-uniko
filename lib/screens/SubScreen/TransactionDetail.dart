import 'package:flutter/material.dart';
import '../../config/theme.config.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import '../../widgets/CategoryDrawer.dart';
import '../../widgets/WalletDrawer.dart';

class TransactionDetailPage extends StatefulWidget {
  final IconData icon;
  final String title;
  final String amount;
  final String date;
  final String category;
  final bool isIncome;

  const TransactionDetailPage({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.isIncome = false,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late ScrollController _scrollController;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        final opacity = (_scrollController.offset / 100).clamp(0, 1);
        if (opacity != _opacity) {
          setState(() => _opacity = opacity.toDouble());
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10 * _opacity,
              sigmaY: 10 * _opacity,
            ),
            child: Container(
              color: AppTheme.background.withOpacity(0.8 * _opacity),
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          color: AppTheme.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined, size: 18),
            ),
            color: AppTheme.textPrimary,
            onPressed: _showEditDrawer,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, size: 18),
            ),
            color: AppTheme.error,
            onPressed: () => _showDeleteDialog(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Header gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 56,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isIncome
                    ? [
                        const Color(0xFF34C759).withOpacity(0.8),
                        const Color(0xFF30B350),
                      ]
                    : [
                        AppTheme.error.withOpacity(0.8),
                        AppTheme.error,
                      ],
              ),
            ),
          ),

          // Content với card số tiền
          Transform.translate(
            offset: const Offset(0, -60),
            child: Column(
              children: [
                // Card số tiền
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (widget.isIncome
                                  ? const Color(0xFF34C759)
                                  : AppTheme.error)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon,
                          size: 32,
                          color: widget.isIncome
                              ? const Color(0xFF34C759)
                              : AppTheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.amount,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'đ',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: (widget.isIncome
                                  ? const Color(0xFF34C759)
                                  : AppTheme.error)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.isIncome
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: widget.isIncome
                                  ? const Color(0xFF34C759)
                                  : AppTheme.error,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isIncome ? 'Thu nhập' : 'Chi tiêu',
                              style: TextStyle(
                                color: widget.isIncome
                                    ? const Color(0xFF34C759)
                                    : AppTheme.error,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Chi tiết giao dịch
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoSection('Thông tin cơ bản', [
                        _buildInfoItem(Icons.title_outlined, 'Tên giao dịch',
                            widget.title),
                        _buildInfoItem(Icons.category_outlined, 'Danh mục',
                            widget.category),
                        _buildInfoItem(
                          Icons.account_balance_wallet_outlined,
                          'Ví',
                          'Ví chính',
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildInfoSection('Thời gian', [
                        _buildInfoItem(
                            Icons.calendar_today_outlined, 'Ngày', widget.date),
                        _buildInfoItem(Icons.schedule_outlined, 'Giờ', '14:30'),
                      ]),
                      if (!widget.isIncome) ...[
                        const SizedBox(height: 20),
                        _buildStatsCard(),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, [String? change]) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                value,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (change != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
              style: const TextStyle(
                color: Color(0xFF34C759),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.textPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: AppTheme.textPrimary,
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
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Xóa giao dịch?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa giao dịch này không?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Xóa',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 20,
                  color: Color(0xFF34C759),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Thống kê chi tiêu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatItem('Tháng này', '2.500.000 đ', '+ 12%'),
          const SizedBox(height: 12),
          _buildStatItem('Trung bình/tháng', '2.100.000 đ'),
        ],
      ),
    );
  }

  void _showEditDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    label: Text(
                      'Hủy',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Text(
                    'Chỉnh sửa giao dịch',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Đã lưu thay đổi'),
                          backgroundColor: AppTheme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.check,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    label: Text(
                      'Lưu',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(color: AppTheme.textSecondary.withOpacity(0.1)),

            // Form content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildEditSection(
                    'Thông tin cơ bản',
                    [
                      _buildEditField(
                        'Tên giao dịch',
                        widget.title,
                        icon: Icons.title_outlined,
                      ),
                      _buildEditField(
                        'Số tiền',
                        widget.amount,
                        icon: Icons.attach_money_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      _buildEditField(
                        'Danh mục',
                        widget.category,
                        icon: Icons.category_outlined,
                        isDropdown: true,
                      ),
                      _buildEditField(
                        'Ví',
                        'Ví chính',
                        icon: Icons.account_balance_wallet_outlined,
                        isDropdown: true,
                        onTap: () {
                          Navigator.pop(context);
                          _showWalletDrawer(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildEditSection(
                    'Thời gian',
                    [
                      _buildEditField(
                        'Ngày',
                        widget.date,
                        icon: Icons.calendar_today_outlined,
                        isDate: true,
                      ),
                      _buildEditField(
                        'Giờ',
                        '14:30',
                        icon: Icons.schedule_outlined,
                        isTime: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildEditSection(
                    'Ghi chú',
                    [
                      _buildEditField(
                        'Ghi chú (tùy chọn)',
                        '',
                        icon: Icons.note_outlined,
                        maxLines: 3,
                        hintText: 'Thêm ghi chú cho giao dịch này...',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildEditField(
    String label,
    String initialValue, {
    IconData? icon,
    bool isDropdown = false,
    bool isDate = false,
    bool isTime = false,
    int maxLines = 1,
    String? hintText,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TextField(
              controller: TextEditingController(text: initialValue),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  fontSize: 15,
                ),
                prefixIcon: icon != null
                    ? Icon(
                        icon,
                        size: 20,
                        color: AppTheme.textSecondary,
                      )
                    : null,
                suffixIcon: isDropdown
                    ? Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.textSecondary,
                      )
                    : (isDate || isTime)
                        ? Icon(
                            isDate ? Icons.calendar_today : Icons.access_time,
                            size: 20,
                            color: AppTheme.textSecondary,
                          )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              readOnly: isDropdown || isDate || isTime,
              onTap: onTap ??
                  () {
                    if (isDropdown) {
                      if (label == 'Danh mục') {
                        _showCategoryDrawer(context, initialValue);
                      }
                    } else if (isDate) {
                      // Show date picker
                    } else if (isTime) {
                      // Show time picker
                    }
                  },
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showSelectionDrawer(
      String title, List<Map<String, dynamic>> items, String currentValue) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: AppTheme.textSecondary.withOpacity(0.1)),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.textSecondary.withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),

            // List items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item['value'] == currentValue;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, item['value']);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: item['color']?.withOpacity(0.1) ??
                                    AppTheme.textSecondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['color'] ?? AppTheme.textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item['label'] as String,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDrawer(BuildContext context, String currentCategory) {
    // Danh sách category tạm thời - bạn có thể thay thế bằng danh sách thực tế
    final categories = [
      CategoryItem(
        emoji: '🛒',
        name: 'Mua sắm',
        color: Colors.blue,
      ),
      CategoryItem(
        emoji: '🍔',
        name: 'Ăn uống',
        color: Colors.orange,
      ),
      CategoryItem(
        emoji: '🚌',
        name: 'Di chuyển',
        color: Colors.green,
      ),
      CategoryItem(
        emoji: '🏥',
        name: 'Sức khỏe',
        color: Colors.red,
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CategoryDrawer(
        currentCategory: currentCategory,
        categories: categories,
        onCategorySelected: (category) {
          // TODO: Xử lý khi category được chọn
          Navigator.pop(context);
        },
        isExpense: true,
      ),
    );
  }

  void _showWalletDrawer(BuildContext context) {
    final wallets = [
      WalletItem(
        icon: Icons.account_balance_wallet,
        name: 'Ví chính',
        color: AppTheme.primary,
        balance: '5.000.000 đ',
        description: 'Ví mặc định',
        isPrimary: true,
      ),
      WalletItem(
        icon: Icons.money,
        name: 'Tiền mặt',
        color: Colors.green,
        balance: '2.000.000 đ',
        description: 'Tiền trong ví',
      ),
      WalletItem(
        icon: Icons.credit_card,
        name: 'Thẻ tín dụng',
        color: Colors.blue,
        balance: '10.000.000 đ',
        description: 'BIDV',
      ),
      WalletItem(
        icon: Icons.savings,
        name: 'Tiết kiệm',
        color: Colors.orange,
        balance: '20.000.000 đ',
        description: 'Kỳ hạn 6 tháng',
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => WalletDrawer(
        currentWallet: 'Ví chính',
        wallets: wallets,
        onWalletSelected: (wallet) {
          // TODO: Cập nhật state với ví được chọn
          _showEditDrawer(); // Mở lại drawer chỉnh sửa
        },
      ),
    );
  }
}
