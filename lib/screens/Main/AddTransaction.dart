import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/core/toast_service.dart';
import 'package:uniko/widgets/LoadingDialog.dart';
import '../../config/theme.config.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:uniko/screens/ChatBot/Chatbot.dart';
import 'package:uniko/widgets/CommonHeader.dart';
import 'package:provider/provider.dart';
import 'package:uniko/providers/account_source_provider.dart';
import 'package:uniko/models/account_source.dart';
import 'package:uniko/providers/fund_provider.dart';
import 'package:uniko/providers/category_provider.dart';
import 'package:uniko/models/category.dart';
import 'package:uniko/widgets/CategoryDrawer.dart';
import 'package:uniko/services/api/tracker_service.dart';
import 'package:uniko/widgets/DatePickerDrawer.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '';
  String _selectedWallet = '';
  String _reasonName = '';
  double _amount = 0;

  final _amountFocusNode = FocusNode();
  final _reasonFocusNode = FocusNode();

  final _descriptionController = TextEditingController();
  final _descriptionFocusNode = FocusNode();

  bool get isExpense => _currentIndex == 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fundProvider = context.read<FundProvider>();
      final selectedFundId = fundProvider.selectedFundId;
      if (selectedFundId != null) {
        context
            .read<AccountSourceProvider>()
            .fetchAccountSources(selectedFundId);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _reasonFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.background,
        appBar: const CommonHeader(
          title: 'Thêm giao dịch',
          showFundSelector: true,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Custom Tab với animation
                Container(
                  height: 40,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  decoration: BoxDecoration(
                    color: AppTheme.isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
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
                          decoration: BoxDecoration(
                            color:
                                _currentIndex == 0 ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(10),
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
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      color: _currentIndex == 0
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    child: const Text('Chi tiêu'),
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
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      color: _currentIndex == 1
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    child: const Text('Thu nhập'),
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
                    child: _buildTransactionForm(),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: "chatbot",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          },
          backgroundColor: AppTheme.primary,
          child: const Icon(Icons.chat_outlined, color: Colors.white),
        ),
      ),
    );
  }

  // Tách form thành widget riêng để tái sử dụng
  Widget _buildTransactionForm() {
    return Column(
      children: [
        // Số tiền
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số tiền',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildAmountField(),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Lí do và phân loại
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
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
              // Lí do
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: _buildReasonField(),
              ),
              Divider(color: AppTheme.borderColor.withOpacity(0.5), height: 1),

              // Phân loại
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _showCategoryDrawer(_currentIndex == 0);
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  title: Consumer<CategoryProvider>(
                    builder: (context, provider, child) {
                      final selectedCategory = provider.categories.firstWhere(
                        (cat) => cat.id == _selectedCategory,
                        orElse: () => Category(
                          id: '',
                          name: 'Chọn phân loại',
                          type: isExpense ? 'EXPENSE' : 'INCOMING',
                          trackerType: 'DEFAULT',
                        ),
                      );
                      return Text(
                        selectedCategory.name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                      );
                    },
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              Divider(color: AppTheme.borderColor.withOpacity(0.5), height: 1),

              // Ngày giao dịch
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _showDatePicker();
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Thời gian',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(_selectedDate)} ${DateFormat('HH:mm').format(_selectedDate)}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Nguồn tiền
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _showWalletDrawer(context);
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Nguồn tiền',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<AccountSourceProvider>(
                        builder: (context, provider, child) {
                          final selectedWallet =
                              provider.accountSources.firstWhere(
                            (wallet) => wallet.id == _selectedWallet,
                            orElse: () => AccountSource(
                                id: '',
                                name: 'Chọn ví',
                                type: '',
                                initAmount: 0,
                                currency: '',
                                currentAmount: 0,
                                userId: '',
                                fundId: ''),
                          );
                          return Text(
                            selectedWallet.name,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Description field với thiết kế mới
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mô tả',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Thêm mô tả (tùy chọn)',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.5),
                    fontSize: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.borderColor.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.borderColor.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isExpense ? Colors.red : Colors.green,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Button với thiết kế mới
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isExpense ? Colors.red : Colors.green).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: isExpense ? Colors.red : Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              isExpense ? 'Thêm chi tiêu' : 'Thêm thu nhập',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Hàm format số tiền
  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) return '';
    final format = NumberFormat("#,###", "vi_VN");
    return format.format(number);
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      focusNode: _amountFocusNode,
      keyboardType: TextInputType.number,
      autofocus: false,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: '0',
        suffixText: 'đ',
        suffixStyle: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      onEditingComplete: () {
        _reasonFocusNode.requestFocus();
      },
      onTapOutside: (event) {
        if (_amountController.text.isNotEmpty) {
          _reasonFocusNode.requestFocus();
        }
      },
      onChanged: (value) {
        // Lưu vị trí con trỏ hiện tại
        final cursorPos = _amountController.selection;
        // Format số tiền
        final formattedValue = _formatNumber(value);

        // Cập nhật text và vị trí con trỏ
        _amountController.value = TextEditingValue(
          text: formattedValue,
          selection: TextSelection.collapsed(
            offset: formattedValue.length,
          ),
        );
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số tiền';
        }
        final amount = double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
        if (amount == null || amount <= 0) {
          return 'Số tiền không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {
        if (value != null) {
          _amount = double.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
        }
      },
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _noteController,
      focusNode: _reasonFocusNode,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: isExpense ? 'Lí do chi tiêu' : 'Lí do thu nhập',
      ),
      onEditingComplete: () {
        _reasonFocusNode.unfocus();
        _showCategoryDrawer(_currentIndex == 0);
      },
      onTapOutside: (event) {
        _reasonFocusNode.unfocus();
        if (_noteController.text.isNotEmpty) {
          _showCategoryDrawer(_currentIndex == 0);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập lý do';
        }
        return null;
      },
      onSaved: (value) {
        _reasonName = value ?? '';
      },
    );
  }

  void _showWalletDrawer(BuildContext context) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<AccountSourceProvider>(
        builder: (context, provider, child) {
          final wallets = provider.accountSources;

          return Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
                if (provider.isLoading)
                  const CircularProgressIndicator()
                else if (wallets.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
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
                  )
                else
                  ...List.generate(
                    wallets.length,
                    (index) => ListTile(
                      leading: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: _selectedWallet == wallets[index].id
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      title: Text(
                        wallets[index].name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: _selectedWallet == wallets[index].id
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: _selectedWallet == wallets[index].id
                          ? Icon(
                              Icons.check_circle,
                              color: AppTheme.primary,
                            )
                          : null,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _selectedWallet = wallets[index].id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleSubmit() async {
    // Unfocus tất cả input trước khi submit
    _amountFocusNode.unfocus();
    _reasonFocusNode.unfocus();
    _descriptionFocusNode.unfocus();
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_selectedCategory.isEmpty) {
        ToastService.showError('Vui lòng chọn phân loại');
        return;
      }

      if (_selectedWallet.isEmpty) {
        ToastService.showError('Vui lòng chọn ví');
        return;
      }

      final fundId = context.read<FundProvider>().selectedFundId;
      if (fundId == null) {
        ToastService.showError('Vui lòng chọn quỹ');
        return;
      }

      try {
        LoadingDialog.show(context);

        await TrackerService.createTracker(
          trackerTypeId: _selectedCategory,
          reasonName: _reasonName,
          direction: isExpense ? 'EXPENSE' : 'INCOMING',
          amount: _amount,
          accountSourceId: _selectedWallet,
          fundId: fundId,
          description: _descriptionController.text.trim(),
        );

        LoadingDialog.hide(context);

        // Clear form và đảm bảo không focus
        _amountController.clear();
        _noteController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = '';
          _selectedWallet = '';
          // Đảm bảo không có input nào được focus
          FocusScope.of(context).unfocus();
        });

        // Thêm unfocus một lần nữa sau khi hoàn tất mọi thứ
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });

        ToastService.showSuccess('Đã thêm giao dịch thành công');
      } catch (e) {
        LoadingDialog.hide(context);
        ToastService.showError('Có lỗi xảy ra khi thêm giao dịch');
        LoggerService.error('Create Tracker Error: $e');
      }
    }
  }

  void _showCategoryDrawer(bool isExpense) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          final categories = provider
              .getCategoriesByType(isExpense ? 'EXPENSE' : 'INCOMING')
              .map((cat) => CategoryItem(
                    emoji: cat.name.split(' ')[0],
                    name: cat.name.split(' ').skip(1).join(' '),
                    color: isExpense ? Colors.red : Colors.green,
                  ))
              .toList();

          return CategoryDrawer(
            currentCategory: _selectedCategory,
            onCategorySelected: (categoryName) {
              FocusScope.of(context).unfocus();
              setState(() {
                _selectedCategory = provider.categories
                    .firstWhere((cat) => cat.name.contains(categoryName))
                    .id;
              });
              Navigator.pop(context);
              _showDatePicker();
            },
            isExpense: isExpense,
          );
        },
      ),
    );
  }

  void _showDatePicker() {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DatePickerDrawer(
        selectedDate: _selectedDate,
        onDateSelected: (date) {
          setState(() => _selectedDate = date);
          Navigator.pop(context);
          _showWalletDrawer(context);
        },
      ),
    );
  }
}
