import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.config.dart';
import 'package:intl/intl.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '';
  String _selectedWallet = '';

  final _amountFocusNode = FocusNode();

  bool get isExpense => _tabController.index == 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch account sources với fundId từ FundProvider
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
    _tabController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      appBar: const CommonHeader(
        title: 'Thêm giao dịch',
        showFundSelector: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Chi tiêu tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
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
                              TextField(
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    color:
                                        AppTheme.textSecondary.withOpacity(0.5),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  suffixText: 'đ',
                                  suffixStyle: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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
                                child: TextField(
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Lí do chi tiêu',
                                    hintStyle: TextStyle(
                                      color: AppTheme.textSecondary
                                          .withOpacity(0.5),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(color: AppTheme.borderColor, height: 1),

                              // Phân loại
                              ListTile(
                                onTap: () => _showCategoryDrawer(
                                    _tabController.index == 0),
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
                                    final selectedCategory =
                                        provider.categories.firstWhere(
                                      (cat) => cat.id == _selectedCategory,
                                      orElse: () => Category(
                                        id: '',
                                        name: 'Chọn phân loại',
                                        type:
                                            isExpense ? 'EXPENSE' : 'INCOMING',
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
                                      DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate),
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
                                          (wallet) =>
                                              wallet.id == _selectedWallet,
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

                        // Mô tả
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
                          child: TextField(
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
                        ),

                        const SizedBox(height: 24),

                        // Button Thêm mới
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Handle add expense
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Thêm chi tiêu',
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

                  // Thu nhập tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
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
                              TextField(
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    color:
                                        AppTheme.textSecondary.withOpacity(0.5),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  suffixText: 'đ',
                                  suffixStyle: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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
                                child: TextField(
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Lí do thu nhập',
                                    hintStyle: TextStyle(
                                      color: AppTheme.textSecondary
                                          .withOpacity(0.5),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(color: AppTheme.borderColor, height: 1),

                              // Phân loại
                              ListTile(
                                onTap: () => _showCategoryDrawer(
                                    _tabController.index == 0),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.work,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                                title: Consumer<CategoryProvider>(
                                  builder: (context, provider, child) {
                                    final selectedCategory =
                                        provider.categories.firstWhere(
                                      (cat) => cat.id == _selectedCategory,
                                      orElse: () => Category(
                                        id: '',
                                        name: 'Chọn phân loại',
                                        type: 'INCOMING',
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
                                      DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate),
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
                                          (wallet) =>
                                              wallet.id == _selectedWallet,
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

                        // Mô tả
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
                          child: TextField(
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
                        ),

                        const SizedBox(height: 24),

                        // Button Thêm mới
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Handle add income
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Thêm thu nhập',
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
                ],
              ),
            ),
          ],
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
    );
  }

  Widget _buildAmountField() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      borderRadius: 16,
      blur: 10,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _tabController.index == 0
              ? AppTheme.error
              : const Color(0xFF34C759),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(
            color: AppTheme.textSecondary.withOpacity(0.3),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          suffixText: 'đ',
          suffixStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms);
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory.isEmpty ? null : _selectedCategory,
      hint: Text('Chọn danh mục'),
      items: (_tabController.index == 0
              ? ['Ăn uống', 'Di chuyển', 'Mua sắm', 'Giải trí', 'Sức khỏe']
              : ['Lương', 'Thưởng', 'Đầu tư', 'Khác'])
          .map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategory = value ?? '');
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showWalletDrawer(BuildContext context) {
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

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save transaction
      Navigator.pop(context);
    }
  }

  Widget _buildExpenseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildAmountField(),
            const SizedBox(height: 24),
            _buildCategoryField(),
            const SizedBox(height: 24),
            _buildDateField(),
            const SizedBox(height: 24),
            _buildWalletField(),
            const SizedBox(height: 24),
            _buildNoteField(),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildAmountField(),
            const SizedBox(height: 24),
            _buildCategoryField(),
            const SizedBox(height: 24),
            _buildDateField(),
            const SizedBox(height: 24),
            _buildWalletField(),
            const SizedBox(height: 24),
            _buildNoteField(),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppTheme.cardBackground.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
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
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar
              Expanded(
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
                    dayBorderRadius: BorderRadius.circular(10),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _showDatePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : AppTheme.borderColor,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                color: AppTheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletField() {
    return InkWell(
      onTap: () => _showWalletDrawer(context),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : AppTheme.borderColor,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppTheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _selectedWallet,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : AppTheme.borderColor,
          width: 0.5,
        ),
      ),
      child: TextFormField(
        controller: _noteController,
        maxLines: 3,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'Thêm ghi chú...',
          hintStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 15,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  void _showCategoryDrawer(bool isExpense) {
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
}
