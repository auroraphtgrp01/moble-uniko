import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import '../models/account_source.dart';
import 'package:intl/intl.dart';

class EditWalletDrawer extends StatefulWidget {
  final AccountSource wallet;
  final Color color;
  final Function(AccountSource) onSave;

  const EditWalletDrawer({
    super.key,
    required this.wallet,
    required this.color,
    required this.onSave,
  });

  @override
  State<EditWalletDrawer> createState() => _EditWalletDrawerState();
}

class _EditWalletDrawerState extends State<EditWalletDrawer> {
  late TextEditingController nameController;
  late TextEditingController initAmountController;
  late TextEditingController currentAmountController;
  late TextEditingController loginIdController;
  late TextEditingController passwordController;
  late TextEditingController accountNoController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.wallet.name);
    initAmountController = TextEditingController(
        text: widget.wallet.initAmount.toString());
    currentAmountController = TextEditingController(
        text: widget.wallet.currentAmount.toString());
    
    if (widget.wallet.type == 'BANKING') {
      loginIdController = TextEditingController(
          text: widget.wallet.accountBank?['login_id']?.toString() ?? '');
      passwordController = TextEditingController(
          text: widget.wallet.accountBank?['pass']?.toString() ?? '');
      accountNoController = TextEditingController(
          text: (widget.wallet.accountBank?['accounts'] as List?)
              ?.firstWhere((acc) => true, orElse: () => {'accountNo': ''})['accountNo']
              ?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    initAmountController.dispose();
    currentAmountController.dispose();
    if (widget.wallet.type == 'BANKING') {
      loginIdController.dispose();
      passwordController.dispose();
      accountNoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.wallet.type == 'WALLET' 
                        ? Icons.account_balance_wallet 
                        : Icons.account_balance,
                    color: widget.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Chỉnh sửa thông tin',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.borderColor.withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          'Tên',
                          nameController,
                          widget.color,
                          prefixIcon: Icons.edit_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Số dư ban đầu',
                          initAmountController,
                          widget.color,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.account_balance_wallet_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Số dư hiện tại',
                          currentAmountController,
                          widget.color,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.payments_outlined,
                        ),
                      ],
                    ),
                  ),

                  // Bank Info Section (if banking)
                  if (widget.wallet.type == 'BANKING') ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.isDarkMode
                            ? Colors.black.withOpacity(0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.borderColor.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_outlined,
                                size: 18,
                                color: widget.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Thông tin ngân hàng',
                                style: TextStyle(
                                  color: widget.color,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Tên đăng nhập',
                            loginIdController,
                            widget.color,
                            prefixIcon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Mật khẩu',
                            passwordController,
                            widget.color,
                            isPassword: true,
                            prefixIcon: Icons.lock_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Số tài khoản',
                            accountNoController,
                            widget.color,
                            prefixIcon: Icons.credit_card_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              border: Border(
                top: BorderSide(
                  color: AppTheme.borderColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: AppTheme.borderColor.withOpacity(0.3),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Color color, {
    bool isPassword = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null ? Icon(
              prefixIcon,
              color: color.withOpacity(0.5),
              size: 20,
            ) : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: color.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: color.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: color.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    // Tạo bản sao của wallet hiện tại
    final updatedWallet = AccountSource(
      id: widget.wallet.id,
      name: nameController.text,
      type: widget.wallet.type,
      initAmount: int.tryParse(initAmountController.text) ?? widget.wallet.initAmount,
      currentAmount: int.tryParse(currentAmountController.text) ?? widget.wallet.currentAmount,
      currency: widget.wallet.currency,
      userId: widget.wallet.userId,
      fundId: widget.wallet.fundId,
      participantId: widget.wallet.participantId,
      accountBankId: widget.wallet.accountBankId,
    );

    // Nếu là tài khoản ngân hàng, cập nhật thông tin ngân hàng
    if (widget.wallet.type == 'BANKING') {
      updatedWallet.accountBank = {
        ...widget.wallet.accountBank ?? {},
        'login_id': loginIdController.text,
        'pass': passwordController.text,
        'accounts': [
          {'accountNo': accountNoController.text}
        ],
      };
    }

    widget.onSave(updatedWallet);
    Navigator.pop(context);
  }
} 