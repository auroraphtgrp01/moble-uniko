// lib/widgets/AddWalletDrawer.dart

import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import '../services/account_source_service.dart';
import '../models/account_source.dart';

enum WalletType {
  cash,
  bank,
}

class AddWalletDrawer extends StatefulWidget {
  final Color color;
  final String fundId; // Thêm tham số fundId

  const AddWalletDrawer({
    super.key,
    required this.color,
    required this.fundId, // Yêu cầu fundId
  });

  @override
  State<AddWalletDrawer> createState() => _AddWalletDrawerState();
}

class _AddWalletDrawerState extends State<AddWalletDrawer> {
  WalletType _selectedType = WalletType.cash;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _accountInputController = TextEditingController();

  List<String> _accounts = []; // Danh sách số tài khoản đã nhập

  bool _isLoading = false; // Biến để hiển thị trạng thái tải

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _accountInputController.dispose();
    super.dispose();
  }

  void _addAccount(String account) {
    final trimmedAccount = account.trim();
    if (trimmedAccount.isNotEmpty && !_accounts.contains(trimmedAccount)) {
      setState(() {
        _accounts.add(trimmedAccount);
      });
    }
  }

  void _removeAccount(String account) {
    setState(() {
      _accounts.remove(account);
    });
  }

  void _handleAccountInput(String value) {
    if (value.endsWith(' ') || value.endsWith(',') || value.endsWith('\n')) {
      final accounts = value.split(RegExp(r'[ ,\n]+'));
      for (var account in accounts) {
        if (account.trim().isNotEmpty) {
          _addAccount(account);
        }
      }
      _accountInputController.clear();
    }
  }

  void _processFinalAccountInput() {
    final accountInput = _accountInputController.text.trim();
    if (accountInput.isNotEmpty) {
      final accounts = accountInput.split(RegExp(r'[ ,\n]+'));
      for (var account in accounts) {
        if (account.trim().isNotEmpty) {
          _addAccount(account);
        }
      }
      _accountInputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thêm nguồn tiền',
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
                    color: AppTheme.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên nguồn tiền
                    _buildLabel('Tên nguồn tiền'),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Nhập tên nguồn tiền',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vui lòng nhập tên nguồn tiền';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Loại nguồn tiền
                    _buildLabel('Loại nguồn tiền'),
                    _buildWalletTypeSelector(),
                    const SizedBox(height: 20),

                    // Tiền khởi tạo
                    _buildLabel('Tiền khởi tạo'),
                    _buildTextField(
                      controller: _amountController,
                      hintText: 'Nhập số tiền',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vui lòng nhập số tiền';
                        }
                        if (int.tryParse(value ?? '') == null) {
                          return 'Vui lòng nhập số tiền hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Mô tả
                    _buildLabel('Mô tả'),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'Nhập mô tả (tùy chọn)',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Các trường cho ngân hàng
                    if (_selectedType == WalletType.bank) ...[
                      _buildLabel('Tên đăng nhập'),
                      _buildTextField(
                        controller: _usernameController,
                        hintText: 'Nhập tên đăng nhập',
                        validator: (value) {
                          if (_selectedType == WalletType.bank &&
                              (value?.isEmpty ?? true)) {
                            return 'Vui lòng nhập tên đăng nhập';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Mật khẩu'),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Nhập mật khẩu',
                        obscureText: true,
                        validator: (value) {
                          if (_selectedType == WalletType.bank &&
                              (value?.isEmpty ?? true)) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Số tài khoản'),
                      _buildAccountInputField(),
                      const SizedBox(height: 10),
                      _buildAccountsChips(),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Thêm nguồn tiền',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 15,
        ),
        filled: true,
        fillColor: AppTheme.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.color,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInputField() {
    return TextFormField(
      controller: _accountInputController,
      decoration: InputDecoration(
        hintText: 'Nhập số tài khoản (cách nhau bằng khoảng trắng hoặc dấu phẩy)',
        hintStyle: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 15,
        ),
        filled: true,
        fillColor: AppTheme.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.color,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
      onChanged: _handleAccountInput,
      onFieldSubmitted: (value) {
        _handleAccountInput(value);
      },
    );
  }

  Widget _buildAccountsChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _accounts.map((account) {
        return Chip(
          label: Text(account),
          deleteIcon: Icon(Icons.close),
          onDeleted: () => _removeAccount(account),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: widget.color),
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.transparent,
          labelStyle: TextStyle(
            color: AppTheme.textPrimary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWalletTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(
              type: WalletType.cash,
              icon: Icons.money,
              label: 'Tiền mặt',
            ),
          ),
          Expanded(
            child: _buildTypeOption(
              type: WalletType.bank,
              icon: Icons.account_balance,
              label: 'Ngân hàng',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required WalletType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? widget.color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() async {
    // Xử lý các số tài khoản còn lại trong trường nhập liệu
    _processFinalAccountInput();

    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedType == WalletType.bank && _accounts.isEmpty) {
        // Nếu là ngân hàng nhưng không có số tài khoản, hiển thị lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng nhập ít nhất một số tài khoản'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final name = _nameController.text.trim();
      final amount = int.parse(_amountController.text.trim());
      final description = _descriptionController.text.trim();
      final fundId = widget.fundId;

      final accountSourceType =
          _selectedType == WalletType.bank ? 'BANKING' : 'WALLET';

      final service = AccountSourceService();

      try {
        final accountSource = await service.createAccountSource(
          name: name,
          accountSourceType: accountSourceType,
          initAmount: amount,
          fundId: fundId,
          accounts: _selectedType == WalletType.bank ? _accounts : null, // Truyền accounts nếu là BANKING
          password: _selectedType == WalletType.bank
              ? _passwordController.text.trim()
              : null,
          loginId: _selectedType == WalletType.bank
              ? _usernameController.text.trim()
              : null,
          type: _selectedType == WalletType.bank ? 'MB_BANK' : null,
        );

        // Thực hiện thêm hành động sau khi tạo thành công, ví dụ:
        Navigator.pop(context, accountSource);
      } catch (e) {
        // Lỗi đã được xử lý trong service bằng ToastService
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
