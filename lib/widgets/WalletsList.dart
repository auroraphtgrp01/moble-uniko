import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import '../screens/FundDetail.dart'; // để import class Wallet

class WalletsList extends StatelessWidget {
  final List<Wallet> wallets;
  final Color color;
  final Function(BuildContext) onAddWallet;

  const WalletsList({
    super.key,
    required this.wallets,
    required this.color,
    required this.onAddWallet,
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
                      _buildWalletItem(wallet),
                      if (wallets.indexOf(wallet) != wallets.length - 1)
                        Divider(
                          color: AppTheme.borderColor,
                          height: 1,
                        ),
                    ],
                  ))
              .toList(),
          Builder(
            builder: (context) => ListTile(
              onTap: () => onAddWallet(context),
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
          ),
        ],
      ),
    );
  }

  Widget _buildWalletItem(Wallet wallet) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: wallet.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          wallet.icon,
          color: wallet.color,
          size: 24,
        ),
      ),
      title: Text(
        wallet.name,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            wallet.description,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
      trailing: Text(
        '${wallet.amount} đ',
        style: TextStyle(
          color: wallet.color,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
