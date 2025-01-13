import 'package:flutter/material.dart';
import 'package:uniko/providers/fund_provider.dart';
import '../config/theme.config.dart';
import 'package:provider/provider.dart';

class FundSelector extends StatelessWidget {
  final String selectedFund;
  final Function(String) onFundChanged;

  FundSelector({
    super.key,
    required this.selectedFund,
    required this.onFundChanged,
  });

  void _showFundDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Chọn quỹ chi tiêu',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: AppTheme.borderColor),
                    // Fund List
                    Expanded(
                      child: Consumer<FundProvider>(
                        builder: (context, fundProvider, _) {
                          final funds = fundProvider.funds;
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: funds.length,
                            itemBuilder: (context, index) {
                              final fund = funds[index];
                              final isSelected = selectedFund == fund.name;
                              
                              return Container(
                                margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppTheme.primary.withOpacity(0.1) 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    onFundChanged(fund.name);
                                    Navigator.pop(context);
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : AppTheme.textSecondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    fund.name,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (fund.description?.isNotEmpty == true) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          fund.description!,
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.textSecondary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${fund.currentAmount} ${fund.currency}',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: isSelected
                                      ? Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFundDrawer(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : AppTheme.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppTheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              selectedFund,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
