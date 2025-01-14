import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import 'package:intl/intl.dart';

class TransactionDetailDrawer extends StatelessWidget {
  final String id;
  final String amount;
  final String? description;
  final DateTime date;
  final String? sourceAccount;
  final String? toAccountNo;
  final String? toAccountName;
  final String? toBankName;
  final bool isIncome;
  final VoidCallback onClassifyPressed;

  const TransactionDetailDrawer({
    super.key,
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    this.sourceAccount,
    this.toAccountNo,
    this.toAccountName,
    this.toBankName,
    required this.isIncome,
    required this.onClassifyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = isIncome ? const Color(0xFF34C759) : AppTheme.error;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drawer Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode 
                ? Colors.white.withOpacity(0.1) 
                : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Main Content
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Amount Card
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  padding: const EdgeInsets.all(24),
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
                  child: Column(
                    children: [
                      // Transaction Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                              color: themeColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isIncome ? 'Thu nhập' : 'Chi tiêu',
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Amount
                      Text(
                        '$amount',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Transaction Details Timeline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildTimelineItem(
                        icon: Icons.description_outlined,
                        color: const Color(0xFFFF9500),
                        title: 'Mô tả',
                        content: description ?? 'Không có mô tả',
                      ),
                      _buildTimelineItem(
                        icon: Icons.schedule,
                        color: const Color(0xFF5856D6),
                        title: 'Thời gian',
                        content: DateFormat('HH:mm, dd/MM/yyyy').format(date),
                      ),
                      _buildTimelineItem(
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppTheme.primary,
                        title: 'Tài khoản nguồn',
                        content: sourceAccount ?? 'Không xác định',
                      ),
                      if (toAccountNo != null) ...[
                        _buildTimelineItem(
                          icon: Icons.account_box_outlined,
                          color: const Color(0xFFAF52DE),
                          title: 'Tài khoản thụ hưởng',
                          content: toAccountNo ?? 'Không xác định',
                          subtitle: toAccountName,
                        ),
                        _buildTimelineItem(
                          icon: Icons.account_balance_outlined,
                          color: const Color(0xFF34C759),
                          title: 'Ngân hàng thụ hưởng',
                          content: toBankName ?? 'Không xác định',
                          isLast: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer với nút phân loại
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: onClassifyPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Phân loại giao dịch',
                      style: TextStyle(
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
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
    String? subtitle,
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
                      ? Colors.white.withOpacity(0.1)
                      : AppTheme.borderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 