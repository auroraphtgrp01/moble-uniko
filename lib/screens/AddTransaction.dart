import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.config.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '';
  String _selectedWallet = 'Ví chính';

  final List<String> _wallets = ['Ví chính', 'Tiền mặt', 'Ngân hàng', 'Momo'];

  final _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_note_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Ghi chép',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _handleSubmit,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lưu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: _tabController.index == 0
                      ? [
                          AppTheme.error.withOpacity(0.8),
                          AppTheme.error,
                        ]
                      : [
                          const Color(0xFF34C759).withOpacity(0.8),
                          const Color(0xFF34C759),
                        ],
                ),
              ),
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: AppTheme.isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : AppTheme.borderColor,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_circle_outline,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text('Chi tiêu'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text('Thu nhập'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Label
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
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

                    // Amount Field
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : AppTheme.borderColor,
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.isDarkMode
                                ? Colors.black.withOpacity(0.2)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            autofocus: false,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                                color: AppTheme.textSecondary.withOpacity(0.5),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              suffixText: 'đ',
                              suffixStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số tiền';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Category Label
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Danh mục',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Category Field
                    InkWell(
                      onTap: () {
                        // TODO: Show category drawer
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : AppTheme.borderColor,
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.isDarkMode
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.category_outlined,
                                color: _selectedCategory.isEmpty
                                    ? AppTheme.textSecondary
                                    : AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedCategory.isEmpty 
                                  ? 'Chọn danh mục' 
                                  : _selectedCategory,
                              style: TextStyle(
                                color: _selectedCategory.isEmpty
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppTheme.textSecondary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Date Label
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ngày giao dịch',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Date Field
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
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
                    ),

                    const SizedBox(height: 24),

                    // Wallet Label
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Nguồn tiền',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Wallet Field
                    InkWell(
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
                    ),

                    const SizedBox(height: 24),

                    // Note Label
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ghi chú',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Note Field
                    Container(
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWalletDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            ...List.generate(
              _wallets.length,
              (index) => ListTile(
                leading: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: _selectedWallet == _wallets[index]
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
                title: Text(
                  _wallets[index],
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: _selectedWallet == _wallets[index]
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                trailing: _selectedWallet == _wallets[index]
                    ? Icon(
                        Icons.check_circle,
                        color: AppTheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() => _selectedWallet = _wallets[index]);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save transaction
      Navigator.pop(context);
    }
  }
} 