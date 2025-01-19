import 'package:flutter/material.dart';
import 'package:uniko/models/tracker_transaction_detail.dart';
import '../config/theme.config.dart';
import 'CategoryDrawer.dart';
import 'package:uniko/widgets/SelectWalletDrawer.dart';
import 'package:uniko/widgets/DatePickerDrawer.dart';
import 'package:uniko/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:uniko/providers/account_source_provider.dart';

class EditTransactionDrawer extends StatefulWidget {
  final TrackerTransactionDetail transaction;
  final Function(TrackerTransactionDetail) onSave;

  const EditTransactionDrawer({
    super.key,
    required this.transaction,
    required this.onSave,
  });

  @override
  _EditTransactionDrawerState createState() => _EditTransactionDrawerState();
}

class _EditTransactionDrawerState extends State<EditTransactionDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late DateTime _selectedDateTime;
  late String _selectedCategoryId;
  late String _selectedWalletId;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _amountController = TextEditingController(
        text: widget.transaction.transaction.amount.toString());
    _selectedDateTime = widget.transaction.time;
    _selectedCategoryId = widget.transaction.trackerType.id;
    _selectedWalletId = widget.transaction.transaction.accountSource.id;
    _currentIndex = widget.transaction.trackerType.type == 'EXPENSE' ? 0 : 1;
  }

  bool get isExpense => _currentIndex == 0;

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Validate các trường bắt buộc
      if (_selectedCategoryId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn danh mục')),
        );
        return;
      }
      if (_selectedWalletId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ví')),
        );
        return;
      }

      // Tạo form data
      final formData = {
        'description': _descriptionController.text.trim(),
        'amount': double.parse(_amountController.text.replaceAll(',', '')),
        'categoryId': _selectedCategoryId,
        'accountSourceId': _selectedWalletId,
        'dateTime': _selectedDateTime.toIso8601String(),
        'type': isExpense ? 'EXPENSE' : 'INCOMING',
        'note': _descriptionController.text.trim(),
        'id': widget.transaction.id,
      };

      // Log ra màn hình
      print('Form Data: $formData');

      // Đóng drawer
      Navigator.pop(context);
    }
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên giao dịch';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số tiền';
    }
    try {
      final amount = double.parse(value.replaceAll(',', ''));
      if (amount <= 0) {
        return 'Số tiền phải lớn hơn 0';
      }
    } catch (e) {
      return 'Số tiền không hợp lệ';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            _buildHeader(context),

            const SizedBox(height: 20),

            // Custom Tab với animation giống AddTransaction
            Container(
              height: 48,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              decoration: BoxDecoration(
                color: AppTheme.isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Stack(
                children: [
                  // Animated Background
                  AnimatedAlign(
                    alignment: _currentIndex == 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 40) / 2,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _currentIndex == 0
                            ? Colors.red.withOpacity(0.9)
                            : Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: (_currentIndex == 0
                                    ? Colors.red
                                    : Colors.green)
                                .withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _currentIndex = 0),
                            borderRadius: BorderRadius.circular(12),
                            splashColor: Colors.red.withOpacity(0.1),
                            highlightColor: Colors.transparent,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.remove_circle_outline,
                                    size: 16,
                                    color: _currentIndex == 0
                                        ? Colors.white
                                        : AppTheme.textSecondary.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      color: _currentIndex == 0
                                          ? Colors.white
                                          : AppTheme.textSecondary.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: _currentIndex == 0
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                    child: const Text('Chi tiêu'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _currentIndex = 1),
                            borderRadius: BorderRadius.circular(12),
                            splashColor: Colors.green.withOpacity(0.1),
                            highlightColor: Colors.transparent,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 16,
                                    color: _currentIndex == 1
                                        ? Colors.white
                                        : AppTheme.textSecondary.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      color: _currentIndex == 1
                                          ? Colors.white
                                          : AppTheme.textSecondary.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: _currentIndex == 1
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                    child: const Text('Thu nhập'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Số tiền field với màu card theo loại giao dịch
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isExpense ? Colors.red : Colors.green).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.payments_outlined,
                                  color: isExpense ? Colors.red : Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Số tiền',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _amountController,
                            validator: _validateAmount,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixText: 'đ',
                              suffixStyle: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Thông tin chi tiết
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Tên giao dịch
                          _buildDetailItem(
                            'Tên giao dịch',
                            Icons.edit_outlined,
                            Colors.blue,
                            TextFormField(
                              controller: _descriptionController,
                              validator: _validateDescription,
                              decoration: InputDecoration(
                                hintText: 'Nhập tên giao dịch',
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          _buildDivider(),

                          // Danh mục
                          _buildDetailItem(
                            'Danh mục',
                            Icons.category_outlined,
                            Colors.orange,
                            Text(
                              getCategoryName(_selectedCategoryId),
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            onTap: () => _showCategoryDrawer(context),
                            showChevron: true,
                          ),

                          _buildDivider(),

                          // Ví
                          _buildDetailItem(
                            'Ví',
                            Icons.account_balance_wallet_outlined,
                            Colors.green,
                            Text(
                              getWalletName(_selectedWalletId),
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            onTap: () => _showWalletDrawer(context),
                            showChevron: true,
                          ),

                          _buildDivider(),

                          // Thời gian
                          _buildDetailItem(
                            'Thời gian',
                            Icons.access_time,
                            Colors.purple,
                            Text(
                              '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            onTap: () => _showDatePicker(context),
                            showChevron: true,
                          ),

                          _buildDivider(),

                          // Mô tả (tùy chọn)
                          _buildDetailItem(
                            'Mô tả (tùy chọn)',
                            Icons.description_outlined,
                            Colors.teal,
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Nhập mô tả chi tiết (nếu có)',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color:
                                      AppTheme.textSecondary.withOpacity(0.5),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nút Lưu
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            label: Text(
              'Hủy',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Text(
            'Chỉnh sửa giao dịch',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    IconData icon,
    Color iconColor,
    Widget content, {
    VoidCallback? onTap,
    bool showChevron = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
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
                  content,
                ],
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.borderColor.withOpacity(0.1),
    );
  }

  void _showCategoryDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryDrawer(
        currentCategory: _selectedCategoryId,
        onCategorySelected: (categoryId) {
          setState(() {
            _selectedCategoryId = categoryId;
          });
        },
        isExpense: true,
        autoPopOnSelect: false,
      ),
    );
  }

  void _showWalletDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectWalletDrawer(
        currentWallet: _selectedWalletId,
        onSelect: (walletId) {
          setState(() {
            _selectedWalletId = walletId;
          });
        },
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DatePickerDrawer(
        selectedDate: _selectedDateTime,
        onDateSelected: (newDateTime) {
          setState(() {
            _selectedDateTime = newDateTime;
          });
        },
        autoPopOnSelect: false,
      ),
    );
  }

  String getCategoryName(String categoryId) {
    final categories = context.read<CategoryProvider>().categories;
    try {
      final category = categories.firstWhere((cat) => cat.id == categoryId);
      return category.name;
    } catch (e) {
      return 'Chọn danh mục';
    }
  }

  String getWalletName(String walletId) {
    final wallets = context.read<AccountSourceProvider>().accountSources;
    try {
      final wallet = wallets.firstWhere((w) => w.id == walletId);
      return wallet.name;
    } catch (e) {
      return 'Chọn ví';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
