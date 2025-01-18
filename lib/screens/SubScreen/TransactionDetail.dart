import 'package:flutter/material.dart';
import '../../config/theme.config.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import '../../widgets/CategoryDrawer.dart';
import '../../widgets/WalletDrawer.dart';
import '../../services/tracker_transaction_service.dart';
import '../../models/tracker_transaction_detail.dart';
import 'package:intl/intl.dart';

class TransactionDetailPage extends StatefulWidget {
  final IconData icon;
  final String title;
  final String amount;
  final String date;
  final String category;
  final bool isIncome;
  final String id;

  const TransactionDetailPage({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.isIncome = false,
    required this.id,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final _trackerTransactionService = TrackerTransactionService();
  TrackerTransactionDetail? _transactionDetail;
  bool _isLoading = false;
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
    _loadTransactionDetail();
  }

  Future<void> _loadTransactionDetail() async {
    setState(() => _isLoading = true);
    try {
      final detail =
          await _trackerTransactionService.getTransactionById(widget.id);
      setState(() {
        _transactionDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
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
      body: _buildDetailContent(),
    );
  }

  Widget _buildDetailContent() {
    if (_isLoading) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          // Skeleton cho card thông tin chính
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : AppTheme.borderColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skeleton cho category và type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 24),

                // Skeleton cho reason name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppTheme.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Skeleton cho amount
                Container(
                  width: 180,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(height: 24),

                // Skeleton cho info chips
                Row(
                  children: [
                    Container(
                      width: 120,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 140,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_transactionDetail == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy thông tin giao dịch',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final transaction = _transactionDetail!;
    final isIncome = transaction.transaction.direction == 'INCOMING';

    return ListView(
      padding: const EdgeInsets.only(top: 100),
      children: [
        // Card thông tin chính
        _buildMainInfoCard(transaction, isIncome),

        // Timeline các thông tin chi tiết
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: _buildTimelineContent(transaction),
        ),
      ],
    );
  }

  Widget _buildMainInfoCard(
      TrackerTransactionDetail transaction, bool isIncome) {
    // Định nghĩa màu sắc theo loại giao dịch
    final Color themeColor = isIncome
        ? const Color(0xFF34C759) // Màu xanh cho thu nhập
        : AppTheme.error; // Màu đỏ cho chi tiêu

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and amount type
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          transaction.trackerType.name.split(' ')[0], // Emoji
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.trackerType.name
                                  .split(' ')
                                  .sublist(1)
                                  .join(' '),
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              transaction.trackerType.description,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isIncome
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isIncome
                                  ? const Color(0xFF34C759)
                                  : AppTheme.error,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isIncome ? 'Thu nhập' : 'Chi tiêu',
                              style: TextStyle(
                                color: isIncome
                                    ? const Color(0xFF34C759)
                                    : AppTheme.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Reason Name với màu động
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          themeColor.withOpacity(0.15),
                          themeColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: themeColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lý do ${isIncome ? "thu nhập" : "chi tiêu"}',
                          style: TextStyle(
                            color: themeColor.withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.label_important_outline_rounded,
                              size: 20,
                              color: themeColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                transaction.reasonName,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Amount
                  Text(
                    _formatCurrency(transaction.transaction.amount),
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Transaction info
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.account_balance_wallet_outlined,
                        transaction.transaction.accountSource.name,
                        AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.schedule,
                        _formatDateTime(
                            transaction.transaction.transactionDateTime),
                        const Color(0xFF5856D6),
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

  Widget _buildTimelineContent(TrackerTransactionDetail transaction) {
    return Column(
      children: [
        // Participant info
        _buildTimelineItem(
          icon: Icons.person_outline_rounded,
          color: const Color(0xFF5856D6),
          title: 'Người thực hiện',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.participant.user.fullName,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.participant.user.email,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Fund info
        _buildTimelineItem(
          icon: Icons.account_balance_rounded,
          color: const Color(0xFF34C759),
          title: 'Quỹ',
          content: Text(
            transaction.fund.name,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Account info if available
        if (transaction.transaction.ofAccount != null)
          _buildTimelineItem(
            icon: Icons.account_box_outlined,
            color: const Color(0xFFAF52DE),
            title: 'Số tài khoản',
            content: Text(
              transaction.transaction.ofAccount!.accountNo,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Description if available
        if (transaction.transaction.description != null)
          _buildTimelineItem(
            icon: Icons.description_outlined,
            color: const Color(0xFFFF9500),
            title: 'Mô tả',
            content: Text(
              transaction.transaction.description!,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Bank name
        if (transaction.transaction.toBankName != null)
          _buildTimelineItem(
            icon: Icons.account_balance,
            color: const Color(0xFF4CAF50),
            title: 'Ngân hàng nhận',
            content: Text(
              transaction.transaction.toBankName!,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Account number
        if (transaction.transaction.toAccountNo != null)
          _buildTimelineItem(
            icon: Icons.account_box,
            color: const Color(0xFFFFC107),
            title: 'Số tài khoản người nhận',
            content: Text(
              transaction.transaction.toAccountNo!,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Account name
        if (transaction.transaction.toAccountName != null)
          _buildTimelineItem(
            icon: Icons.person,
            color: const Color(0xFF2196F3),
            title: 'Tên tài khoản người nhận',
            content: Text(
              transaction.transaction.toAccountName!,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            isLast: true,
          ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color color,
    required String title,
    required Widget content,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color.withOpacity(0.5),
                            color.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  content,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
        emoji: '🍴',
        name: 'Ăn uống',
        color: Colors.orange,
      ),
      CategoryItem(
        emoji: '🚌',
        name: 'Di chuyển',
        color: Colors.green,
      ),
      CategoryItem(
        emoji: '🏋',
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

  String _formatCurrency(int amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return format.format(amount);
  }

  Widget _buildStatItem(String label, String value, [String? change]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (change != null) ...[
              const SizedBox(width: 8),
              Text(
                change,
                style: TextStyle(
                  color: change.startsWith('+')
                      ? const Color(0xFF34C759)
                      : AppTheme.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatDateTime(DateTime utcTime) {
    // Chuyển đổi UTC sang UTC+7
    final localTime = utcTime.add(const Duration(hours: 7));
    return DateFormat('HH:mm, dd/MM/yyyy').format(localTime);
  }
}

class _TransactionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TrackerTransactionDetail transaction;
  final bool isIncome;
  final double opacity;

  _TransactionHeaderDelegate({
    required this.transaction,
    required this.isIncome,
    required this.opacity,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / maxExtent;

    return Container(
      height: maxExtent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isIncome
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

          // Pattern overlay
          Opacity(
            opacity: (1 - progress).clamp(0.0, 1.0),
            child: Stack(
              children: [
                Positioned(
                  right: -100,
                  top: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -50,
                  bottom: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Blur overlay when scrolling
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
              decoration: BoxDecoration(
                color: AppTheme.background.withOpacity(opacity * 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 200;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate is _TransactionHeaderDelegate &&
      (oldDelegate.transaction != transaction ||
          oldDelegate.isIncome != isIncome ||
          oldDelegate.opacity != opacity);
}
