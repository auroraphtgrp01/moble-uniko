import 'package:flutter/material.dart';
import '../models/account_source.dart';
import '../config/theme.config.dart';
import 'package:intl/intl.dart';

class WalletsList extends StatelessWidget {
  final List<AccountSource> wallets;
  final Color color;
  final VoidCallback onAddWallet;
  final Function(AccountSource) onTapWallet;

  const WalletsList({
    super.key,
    required this.wallets,
    required this.color,
    required this.onAddWallet,
    required this.onTapWallet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ...wallets
              .map((wallet) => Column(
                    children: [
                      _buildWalletItem(context, wallet),
                      if (wallets.indexOf(wallet) != wallets.length - 1)
                        Divider(color: AppTheme.borderColor, height: 1),
                    ],
                  ))
              .toList(),
          Divider(color: AppTheme.borderColor, height: 1),
          ListTile(
            onTap: onAddWallet,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: color,
                size: 24,
              ),
            ),
            title: Text(
              'Thêm nguồn tiền',
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletItem(BuildContext context, AccountSource wallet) {
    final color = _getSourceColor(wallet.type);
    
    return InkWell(
      onTap: () => onTapWallet(wallet),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            // Icon với gradient background
            Container(
              padding: const EdgeInsets.all(12),
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
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getSourceIcon(wallet.type),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 18),
            
            // Thông tin wallet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      wallet.type == 'WALLET' ? 'Tiền mặt' : 'Ngân hàng',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Số tiền
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(
                    locale: 'vi_VN',
                    symbol: wallet.currency,
                    decimalDigits: 0,
                  ).format(wallet.currentAmount),
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),

                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      wallet.currentAmount >= wallet.initAmount 
                          ? Icons.trending_up 
                          : Icons.trending_down,
                      color: wallet.currentAmount >= wallet.initAmount 
                          ? Colors.green 
                          : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: '',
                        decimalDigits: 0,
                      ).format((wallet.currentAmount - wallet.initAmount).abs()),
                      style: TextStyle(
                        color: wallet.currentAmount >= wallet.initAmount 
                            ? Colors.green 
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: color.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSourceColor(String type) {
    if (type == 'WALLET') return const Color(0xFF1E88E5); // Xanh dương đậm
    return const Color(0xFFFF9800); // Cam đậm
  }

  IconData _getSourceIcon(String type) {
    if (type == 'WALLET') return Icons.account_balance_wallet;
    return Icons.account_balance;
  }
}

