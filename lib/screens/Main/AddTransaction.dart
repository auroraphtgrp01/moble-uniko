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
import 'package:uniko/widgets/SelectWalletDrawer.dart';

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
                                            : AppTheme.textSecondary
                                                .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 8),
                                      AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        style: TextStyle(
                                          color: _currentIndex == 0
                                              ? Colors.white
                                              : AppTheme.textSecondary
                                                  .withOpacity(0.7),
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
                                            : AppTheme.textSecondary
                                                .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 8),
                                      AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        style: TextStyle(
                                          color: _currentIndex == 1
                                              ? Colors.white
                                              : AppTheme.textSecondary
                                                  .withOpacity(0.7),
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
        _buildAmountField(),
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
              _buildReasonField(),

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

              // Ghi chú - thêm mới
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(left: 0, top: 5),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: Colors.deepOrange,
                      size: 20,
                    ),
                  ),
                  title: Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: TextFormField(
                      controller: _descriptionController,
                      focusNode: _descriptionFocusNode,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Thêm ghi chú (tùy chọn)',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.5),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Button với thiết kế mới
        Container(
          width: double.infinity,
          height: 48,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            (isExpense ? const Color.fromARGB(255, 211, 60, 49) : Colors.green)
                .withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isExpense ? Colors.red : Colors.green).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Label và Icon
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isExpense ? Colors.red : Colors.green)
                        .withOpacity(0.1),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Input số tiền
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.5),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _amount =
                            double.parse(value.replaceAll(RegExp(r'[.,]'), ''));
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số tiền';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null && value.isNotEmpty) {
                        _amount =
                            double.parse(value.replaceAll(RegExp(r'[.,]'), ''));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'đ',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(left: 0, top: 5),
          decoration: BoxDecoration(
            color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isExpense ? Icons.shopping_bag : Icons.attach_money,
            color: isExpense ? Colors.red : Colors.green,
            size: 20,
          ),
        ),
        title: Container(
          margin: const EdgeInsets.only(top: 5),
          child: TextFormField(
            controller: _noteController,
            focusNode: _reasonFocusNode,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: isExpense ? 'Lí do chi tiêu' : 'Lí do thu nhập',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.5),
                fontSize: 15,
              ),

              isDense: true,
              border: InputBorder.none, // Bỏ border mặc định
              enabledBorder: InputBorder.none, // Bỏ border khi enabled
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
          ),
        ),
      ),
    );
  }

  void _showWalletDrawer(BuildContext context) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectWalletDrawer(
        currentWallet: _selectedWallet,
        onSelect: (walletId) {
          setState(() => _selectedWallet = walletId);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleSubmit() async {
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

        _amountController.clear();
        _noteController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = '';
          _selectedWallet = '';
          FocusScope.of(context).unfocus();
        });

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

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final number =
        int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) return oldValue;

    final formatted = NumberFormat("#,###", "vi_VN").format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
