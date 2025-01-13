import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/core/toast_service.dart';
import 'package:uniko/widgets/LoadingDialog.dart';
import '../../config/theme.config.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
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

  final _descriptionController = TextEditingController();

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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số tiền',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              _buildAmountField(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Lí do và phân loại
        Container(
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
              // Lí do
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildReasonField(),
              ),
              Divider(color: AppTheme.borderColor, height: 1),

              // Phân loại
              ListTile(
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
              Divider(color: AppTheme.borderColor, height: 1),

              // Ngày giao dịch
              ListTile(
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
                  'Ngày giao dịch',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
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

              // Nguồn tiền
              ListTile(
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
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Description field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mô tả',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Thêm mô tả (tùy chọn)',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.5),
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Button Thêm mới
        _buildSubmitButton(),
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
      keyboardType: TextInputType.number,
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
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: isExpense ? 'Lí do chi tiêu' : 'Lí do thu nhập',
      ),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: isExpense ? Colors.red : Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Validate các trường bắt buộc
      if (_selectedCategory.isEmpty) {
        ToastService.showError('Vui lòng chọn phân loại');
        return;
      }

      if (_selectedWallet.isEmpty) {
        ToastService.showError('Vui lòng chọn ví');
        return;
      }

      // Lấy fundId từ FundProvider
      final fundId = context.read<FundProvider>().selectedFundId;
      if (fundId == null) {
        ToastService.showError('Vui lòng chọn quỹ');
        return;
      }

      try {
        // Show loading
        LoadingDialog.show(context);

        // Call API
        await TrackerService.createTracker(
          trackerTypeId: _selectedCategory,
          reasonName: _reasonName,
          direction: isExpense ? 'EXPENSE' : 'INCOMING',
          amount: _amount,
          accountSourceId: _selectedWallet,
          fundId: fundId,
          description: _descriptionController.text.trim(),
        );

        // Hide loading
        LoadingDialog.hide(context);

        // Show success message
        ToastService.showSuccess('Đã thêm giao dịch thành công');

        // Clear form
        _amountController.clear();
        _noteController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = '';
          _selectedWallet = '';
        });
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
            categories: categories,
            onCategorySelected: (categoryName) {
              setState(() {
                _selectedCategory = provider.categories
                    .firstWhere((cat) => cat.name.contains(categoryName))
                    .id;
              });
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
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  'Chọn ngày',
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
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Calendar
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.single,
                selectedDayHighlightColor: AppTheme.primary,
                weekdayLabels: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'],
                weekdayLabelTextStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                dayTextStyle: TextStyle(
                  color: AppTheme.textPrimary,
                ),
                selectedDayTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                dayBorderRadius: BorderRadius.circular(8),
              ),
              value: [_selectedDate],
              onValueChanged: (dates) {
                if (dates.isNotEmpty) {
                  setState(() => _selectedDate = dates.first!);
                  Navigator.pop(context);
                }
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
