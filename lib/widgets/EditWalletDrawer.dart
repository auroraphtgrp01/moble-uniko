import 'package:flutter/material.dart';
import 'package:uniko/services/account_source_service.dart';
import 'package:uniko/services/core/toast_service.dart';
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
  TextEditingController? loginIdController;
  TextEditingController? passwordController;
  TextEditingController? accountNoController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.wallet.name);
    initAmountController =
        TextEditingController(text: widget.wallet.initAmount.toString());
    currentAmountController =
        TextEditingController(text: widget.wallet.currentAmount.toString());

    if (widget.wallet.type == 'BANKING') {
      loginIdController = TextEditingController(
          text: widget.wallet.accountBank?['login_id']?.toString() ?? '');
      passwordController = TextEditingController(
          text: widget.wallet.accountBank?['pass']?.toString() ?? '');

      final accountList = (widget.wallet.accountBank?['accounts'] as List?)
              ?.map((acc) => acc['accountNo']?.toString())
              .where((acc) => acc != null)
              .toList() ??
          [];

      accountNoController = TextEditingController(
        text: accountList.isNotEmpty ? accountList.join(' ') : '',
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    initAmountController.dispose();
    currentAmountController.dispose();
    loginIdController?.dispose();
    passwordController?.dispose();
    accountNoController?.dispose();
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
                            loginIdController!,
                            widget.color,
                            prefixIcon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Mật khẩu',
                            passwordController!,
                            widget.color,
                            isPassword: true,
                            prefixIcon: Icons.lock_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Số tài khoản',
                            accountNoController!,
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
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: color.withOpacity(0.5),
                    size: 20,
                  )
                : null,
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

  void _handleSave() async {
    final accountSourceService = AccountSourceService();

    try {
      final name = nameController.text;
      final initAmount =
          int.tryParse(initAmountController.text) ?? widget.wallet.initAmount;
      final accountSourceType = widget.wallet.type;

      // Tách chuỗi số tài khoản thành danh sách
      final accountNumbers = accountNoController?.text
          .split(' ') // Tách bằng dấu cách
          .where((number) => number.isNotEmpty) // Bỏ qua các chuỗi rỗng
          .toList();

      // Xây dựng body
      final Map<String, dynamic> params = {
        'accountSourceId': widget.wallet.id,
        'accountSourceType': accountSourceType,
        if (name.isNotEmpty) 'name': name,
      };

      if (accountSourceType == 'BANKING') {
        params['loginId'] = loginIdController?.text;
        params['password'] = passwordController?.text;
        params['accounts'] = accountNumbers; // Gán danh sách số tài khoản
      }

      // Gọi API để cập nhật
      final updatedWallet = await accountSourceService.updateAccountSource(
        accountSourceId: widget.wallet.id,
        accountSourceType: accountSourceType,
        name: params['name'] as String?,
        password: params['password'] as String?,
        loginId: params['loginId'] as String?,
        accounts: params['accounts'] as List<String>?, // Ép kiểu danh sách
      );

      // Thông báo và cập nhật UI
      widget.onSave(updatedWallet);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      ToastService.showError('Có lỗi xảy ra khi lưu: $e');
    }
  }
}
