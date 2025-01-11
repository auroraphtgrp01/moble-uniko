import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import '../models/account_source.dart';
import 'package:intl/intl.dart';

class WalletDetailDrawer extends StatelessWidget {
  final AccountSource wallet;
  final Color color;

  const WalletDetailDrawer({
    super.key,
    required this.wallet,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Thay thế gradient background bằng màu đơn giản
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // Drawer Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildBalanceCard(),
                      const SizedBox(height: 32),
                      _buildQuickActions(),
                      const SizedBox(height: 32),
                      _buildWalletInfo(),
                      if (wallet.type == 'BANKING') ...[
                        const SizedBox(height: 32),
                        _buildBankAccounts(),
                      ],
                      const SizedBox(height: 32),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            wallet.type == 'WALLET' ? Icons.account_balance_wallet : Icons.account_balance,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wallet.name,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      wallet.type == 'WALLET' ? Icons.wallet : Icons.credit_card,
                      color: color,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      wallet.type == 'WALLET' ? 'Tiền mặt' : 'Tài khoản ngân hàng',
                      style: TextStyle(
                        color: color,
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
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                'Số dư hiện tại',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.currency_exchange,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: wallet.currency,
              decimalDigits: 0,
            ).format(wallet.currentAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _buildBalanceInfoItem('Số dư ban đầu', wallet.initAmount)),
                  VerticalDivider(
                    color: Colors.white.withOpacity(0.2),
                    thickness: 1,
                    width: 24,
                  ),
                  Expanded(
                    child: _buildBalanceInfoItem(
                      'Thay đổi',
                      wallet.currentAmount - wallet.initAmount,
                      showSign: true,
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

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickActionItem(Icons.add_circle_outline, 'Thu', Colors.green),
        _buildQuickActionItem(Icons.remove_circle_outline, 'Chi', Colors.red),
        _buildQuickActionItem(Icons.sync, 'Chuyển khoản', Colors.blue),
        _buildQuickActionItem(Icons.history, 'Lịch sử', Colors.orange),
      ],
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color iconColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin nguồn tiền',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'Loại nguồn tiền',
                wallet.type == 'WALLET' ? 'Tiền mặt' : 'Tài khoản ngân hàng',
                Icons.account_balance_wallet,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Số dư ban đầu',
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: wallet.currency,
                  decimalDigits: 0,
                ).format(wallet.initAmount),
                Icons.money,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankAccounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tài khoản liên kết',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ...(wallet.accounts ?? []).map((account) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildInfoRow(
                  'Số tài khoản',
                  account,
                  Icons.credit_card,
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // TODO: Implement edit
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Chỉnh sửa'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement delete
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceInfoItem(String label, int amount, {bool showSign = false}) {
    final isPositive = amount >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${showSign && isPositive ? '+' : ''}${NumberFormat.currency(
            locale: 'vi_VN',
            symbol: wallet.currency,
            decimalDigits: 0,
          ).format(amount)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
} 