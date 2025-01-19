import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniko/config/theme.config.dart';
import 'package:uniko/providers/account_source_provider.dart';

class SelectWalletDrawer extends StatelessWidget {
  final String? currentWallet;
  final Function(String) onSelect;

  const SelectWalletDrawer({
    super.key,
    this.currentWallet,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chọn nguồn tiền',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Consumer<AccountSourceProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const CircularProgressIndicator();
              }

              final wallets = provider.accountSources;
              if (wallets.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                children: List.generate(
                  wallets.length,
                  (index) => ListTile(
                    leading: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: currentWallet == wallets[index].id
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    title: Text(
                      wallets[index].name,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: currentWallet == wallets[index].id
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: currentWallet == wallets[index].id
                        ? Icon(
                            Icons.check_circle,
                            color: AppTheme.primary,
                          )
                        : null,
                    onTap: () {
                      onSelect(wallets[index].id);
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có nguồn tiền nào',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vui lòng thêm ví hoặc tài khoản ngân hàng',
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
