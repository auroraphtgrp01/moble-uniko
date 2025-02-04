import 'package:flutter/material.dart';
import '../../config/theme.config.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import '../../widgets/CategoryDrawer.dart';
import '../../widgets/WalletDrawer.dart';
import '../../services/tracker_transaction_service.dart';
import '../../models/tracker_transaction_detail.dart';
import 'package:intl/intl.dart';
import '../../widgets/EditTransactionDrawer.dart';

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
        final scrollPosition = _scrollController.offset;
        final opacity = (scrollPosition / 180).clamp(0.0, 1.0);
        if (opacity != _opacity) {
          setState(() => _opacity = opacity);
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

      // Simplified AppBar with new design
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.cardBackground.withOpacity(0.8),
                    AppTheme.cardBackground.withOpacity(0.0),
                  ],
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'Chi tiết giao dịch',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      // Updated floating action buttons with larger size
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'edit',
              backgroundColor: AppTheme.cardBackground,
              onPressed: _showEditDrawer,
              child: Icon(
                Icons.edit_outlined,
                color: AppTheme.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'delete',
              backgroundColor: AppTheme.error,
              onPressed: () => _showDeleteDialog(context),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: _buildDetailContent(),
    );
  }

  Widget _buildDetailContent() {
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
      ),
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_transactionDetail != null) ...[
          _buildMainInfoCard(_transactionDetail!, widget.isIncome),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildTimelineContent(_transactionDetail!),
                const SizedBox(height: 16),
                _buildMonthlySpending(
                    _transactionDetail!.monthlySpendingByTrackerType),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
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

  void _showEditDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTransactionDrawer(
        transaction: _transactionDetail!,
        onSave: (updatedTransaction) {
          // Xử lý khi lưu transaction
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

  Widget _buildMonthlySpending(MonthlySpendingByTrackerType? monthlySpending) {
    if (monthlySpending == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : AppTheme.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với icon và title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5856D6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF5856D6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Thống kê chi tiêu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tổng chi tiêu card với gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF5856D6).withOpacity(0.15),
                  const Color(0xFF5856D6).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF5856D6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng chi tiêu tháng này',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5856D6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF5856D6).withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: const Color(0xFF5856D6),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+12%',
                            style: TextStyle(
                              color: const Color(0xFF5856D6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                          .format(monthlySpending.sum),
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Cập nhật ${DateFormat('HH:mm').format(_convertToVietnamTime(DateTime.now()))}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Giao dịch gần đây
          Text(
            'Giao dịch gần đây',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Danh sách giao dịch gần đây
          ...monthlySpending.recentTransactions.map((transaction) {
            final isExpense = transaction.transaction.direction == 'EXPENSE';
            final color = isExpense ? AppTheme.error : const Color(0xFF34C759);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 24, // Increased bottom padding
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Transaction Type Indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
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
                            Expanded(
                              child: Text(
                                transaction.reasonName,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                                decimalDigits: 0,
                              ).format(transaction.transaction.amount),
                              style: TextStyle(
                                color: color,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('HH:mm, dd/MM/yyyy').format(
                                _convertToVietnamTime(transaction
                                    .transaction.transactionDateTime),
                              ),
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
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isExpense ? 'Chi tiêu' : 'Thu nhập',
                                style: TextStyle(
                                  color: color,
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
            );
          }).toList(),
        ],
      ),
    );
  }

  DateTime _convertToVietnamTime(DateTime utcTime) {
    // Chuyển đổi UTC sang UTC+7
    return utcTime.add(const Duration(hours: 7));
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
