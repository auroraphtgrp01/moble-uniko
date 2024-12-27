import 'package:flutter/material.dart';
import '../config/theme.config.dart';

class FundSelector extends StatelessWidget {
  final String selectedFund;
  final Function(String) onFundChanged;
  final List<String> funds = [
    'Tất cả',
    'Quỹ cá nhân',
    'Quỹ gia đình',
    'Quỹ đầu tư'
  ];

  FundSelector({
    super.key,
    required this.selectedFund,
    required this.onFundChanged,
  });

  void _showFundDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.borderColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn quỹ',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: funds.length,
                itemBuilder: (context, index) {
                  final fund = funds[index];
                  return ListTile(
                    onTap: () {
                      onFundChanged(fund);
                      Navigator.pop(context);
                    },
                    leading: Icon(
                      Icons.account_balance_wallet,
                      color: selectedFund == fund
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    title: Text(
                      fund,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: selectedFund == fund
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: selectedFund == fund
                        ? Icon(
                            Icons.check_circle,
                            color: AppTheme.primary,
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
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