import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uniko/screens/ChatBot/Chatbot.dart';
import 'package:uniko/services/core/logger_service.dart';
import '../../config/theme.config.dart';
import '../SubScreen/FundDetail.dart';
import 'package:uniko/widgets/FundSelector.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uniko/models/expenditure_fund.dart';
import '../../services/expenditure_service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String _selectedFund = 'Tất cả';
  List<ExpenditureFund> _funds = [];
  bool _isLoading = true;
  final _expenditureService = ExpenditureService();

  @override
  void initState() {
    super.initState();
    _loadFunds();
  }

  Future<void> _loadFunds() async {
    try {
      final response = await _expenditureService.getFunds();
      setState(() {
        _funds = response.data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading funds: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadFunds();
  }

  void _showAddFundDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFundDrawer(
        color: AppTheme.primary,
        onSuccess: () => _loadFunds(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.isDarkMode
                        ? AppTheme.background.withOpacity(0.45)
                        : Colors.white.withOpacity(0.45),
                    AppTheme.isDarkMode
                        ? AppTheme.background.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.isDarkMode
                        ? Colors.white.withOpacity(0.03)
                        : Colors.black.withOpacity(0.03),
                    width: 0.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.isDarkMode
                        ? Colors.black.withOpacity(0.08)
                        : Colors.white.withOpacity(0.6),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ví & Quỹ',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tháng ${DateFormat('MM/yyyy').format(DateTime.now())}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            FundSelector(
              selectedFund: _selectedFund,
              onFundChanged: (fund) => setState(() => _selectedFund = fund),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.primary,
        backgroundColor: AppTheme.cardBackground,
        edgeOffset: MediaQuery.of(context).padding.top + 80,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 80),
            Expanded(
              child: _buildFundsTab(),
            ),
          ],
        ),
      ),
      // Trong Scaffold
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "addFund",
              onPressed: () => _showAddFundDrawer(context),
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "chatbot",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChatbotScreen()),
                );
              },
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.chat_outlined, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalance() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.8),
            AppTheme.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng tài sản',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+12.5%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '54,320,000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFundsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_funds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có quỹ nào',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _funds.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final fund = _funds[index];
        return _buildFundItem(
          index,
          fund.name,
          NumberFormat.currency(
            locale: 'vi_VN',
            symbol: fund.currency,
            decimalDigits: 0,
          ).format(fund.currentAmount),
          _getIconForFund(fund),
          _getFundColor(index),
          '${fund.countParticipants} thành viên',
          fund.description ?? 'Không có mô tả',
        );
      },
    );
  }

  IconData _getIconForFund(ExpenditureFund fund) {
    if (fund.defaultForUser != null) {
      return Icons.person;
    }
    switch (fund.countParticipants) {
      case 1:
        return Icons.person;
      case 2:
        return Icons.favorite;
      case > 2:
        return Icons.group;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getFundColor(int index) {
    final colors = [
      const Color(0xFF4E73F8), // Blue
      const Color(0xFF00C48C), // Green
      const Color(0xFFFFA26B), // Orange
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF7F3DFF), // Purple
      const Color(0xFFFFB800), // Yellow
    ];
    return colors[index % colors.length];
  }

  Widget _buildFundItem(int index, String name, String amount, IconData icon,
      Color color, String members, String description) {
    return GestureDetector(
      onTap: () {
        final fund = _funds[index];
        _navigateToScreen(
          FundDetail(
            fundId: fund.id,
            name: fund.name,
            amount: NumberFormat.currency(
              locale: 'vi_VN',
              symbol: fund.currency,
              decimalDigits: 0,
            ).format(fund.currentAmount),
            color: color,
            description: fund.description ?? 'Không có mô tả',
            members: fund.participants
                .map((p) => Member(
                      name: p.user.fullName,
                      email: p.user.email,
                      avatar: p.user.avatarId != null
                          ? p.user.avatarId!
                          : 'https://i.pravatar.cc/150?img=1',
                      status: p.status,
                      history: ['Tham gia quỹ với vai trò ${p.role}'],
                    ))
                .toList(),
            wallets: [], // Tạm thời để trống vì API chưa có data wallets
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$amount',
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.group,
                        color: color,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        members,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWalletIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'bank':
        return Icons.account_balance;
      case 'ewallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.attach_money;
    }
  }

  Color _getWalletColor(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return const Color(0xFF00C48C);
      case 'bank':
        return const Color(0xFF4E73F8);
      case 'ewallet':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF7F3DFF);
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class AddFundDrawer extends StatefulWidget {
  final Color color;
  final VoidCallback onSuccess;

  const AddFundDrawer({
    super.key,
    required this.color,
    required this.onSuccess,
  });

  @override
  State<AddFundDrawer> createState() => _AddFundDrawerState();
}

class _AddFundDrawerState extends State<AddFundDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final List<String> _invitedEmails = [];
  final _expenditureService = ExpenditureService();
  bool _isLoading = false;
  String _selectedCurrency = 'VND'; // Có thể thêm option USD nếu cần

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _expenditureService.createFund(
          name: _nameController.text,
          currency: _selectedCurrency,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context); // Đóng drawer trước
          widget.onSuccess(); // Sau đó gọi callback để refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
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
                  'Tạo quỹ mới',
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
                    // Tên quỹ
                    _buildLabel('Tên quỹ'),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Nhập tên quỹ',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vui lòng nhập tên quỹ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Mô tả
                    _buildLabel('Mô tả'),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'Nhập mô tả quỹ',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Mời thành viên
                    _buildLabel('Mời thành viên'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _emailController,
                            hintText: 'Nhập email thành viên',
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _addEmail,
                          style: IconButton.styleFrom(
                            backgroundColor: widget.color,
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Danh sách email đã thêm
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _invitedEmails
                          .map((email) => Chip(
                                label: Text(
                                  email,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                backgroundColor: widget.color,
                                deleteIcon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                onDeleted: () => _removeEmail(email),
                              ))
                          .toList(),
                    ),
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
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Tạo quỹ',
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

  void _addEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !_invitedEmails.contains(email)) {
      setState(() {
        _invitedEmails.add(email);
        _emailController.clear();
      });
    }
  }

  void _removeEmail(String email) {
    setState(() {
      _invitedEmails.remove(email);
    });
  }
}
