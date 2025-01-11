import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.config.dart';
import '../../models/account_source.dart';

class WalletDetail extends StatefulWidget {
  final AccountSource wallet;

  const WalletDetail({
    super.key,
    required this.wallet,
  });

  @override
  State<WalletDetail> createState() => _WalletDetailState();
}

class _WalletDetailState extends State<WalletDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.wallet.name,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              _buildBalanceCard(),
              const SizedBox(height: 24),

              // Wallet Info
              _buildWalletInfo(),
              const SizedBox(height: 24),

              // Recent Transactions
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getWalletColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Số dư hiện tại',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: widget.wallet.currency,
              decimalDigits: 0,
            ).format(widget.wallet.currentAmount),
            style: TextStyle(
              color: _getWalletColor(),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Loại nguồn tiền',
            widget.wallet.type == 'WALLET' ? 'Tiền mặt' : 'Tài khoản ngân hàng',
            Icons.account_balance_wallet,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            'Số dư ban đầu',
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: widget.wallet.currency,
              decimalDigits: 0,
            ).format(widget.wallet.initAmount),
            Icons.money,
          ),
          if (widget.wallet.type == 'BANKING') ...[
            const Divider(height: 24),
            _buildInfoRow(
              'Tài khoản liên kết',
              '${widget.wallet.accounts?.length ?? 0} tài khoản',
              Icons.account_balance,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getWalletColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: _getWalletColor(),
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
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giao dịch gần đây',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có giao dịch nào',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getWalletColor() {
    switch (widget.wallet.type.toUpperCase()) {
      case 'WALLET':
        return const Color(0xFF00C48C);
      case 'BANKING':
        return const Color(0xFF4E73F8);
      default:
        return const Color(0xFF7F3DFF);
    }
  }
}
