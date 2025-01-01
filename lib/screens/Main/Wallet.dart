import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uniko/screens/ChatBot/Chatbot.dart';
import '../../config/theme.config.dart';
import '../SubScreen/FundDetail.dart';
import 'package:uniko/widgets/FundSelector.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String _selectedFund = 'Tất cả';

  void _showAddFundDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFundDrawer(color: AppTheme.primary),
    );
  }

  Future<void> _onRefresh() async {
    // Giả lập loading trong 1.5 giây
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      // Thêm logic cập nhật dữ liệu ở đây
    });
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
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'đ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFundsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildFundItem(
          'Quỹ cá nhân',
          '35,320,000',
          Icons.person,
          const Color(0xFF4E73F8),
          '1 thành viên',
          'Quỹ mặc định',
        ),
        const SizedBox(height: 16),
           _buildFundItem(
          'Quỹ cá nhân',
          '35,320,000',
          Icons.person,
          const Color(0xFF4E73F8),
          '1 thành viên',
          'Quỹ mặc định',
        ),
        const SizedBox(height: 16),
           _buildFundItem(
          'Quỹ cá nhân',
          '35,320,000',
          Icons.person,
          const Color(0xFF4E73F8),
          '1 thành viên',
          'Quỹ mặc định',
        ),
        const SizedBox(height: 16),
           _buildFundItem(
          'Quỹ cá nhân',
          '35,320,000',
          Icons.person,
          const Color(0xFF4E73F8),
          '1 thành viên',
          'Quỹ mặc định',
        ),
        const SizedBox(height: 16),
        _buildFundItem(
          'Quỹ gia đình',
          '25,500,000',
          Icons.family_restroom,
          const Color(0xFF00C48C),
          '4 thành viên',
          'Quỹ chung với gia đình',
        ),
        const SizedBox(height: 16),
        _buildFundItem(
          'Quỹ du lịch',
          '12,800,000',
          Icons.card_travel,
          const Color(0xFFFFA26B),
          '3 thành viên',
          'Quỹ đi chơi với bạn bè',
        ),
        const SizedBox(height: 16),
        _buildFundItem(
          'Quỹ đầu tư',
          '8,500,000',
          Icons.trending_up,
          const Color(0xFFFF6B6B),
          '2 thành viên',
          'Đầu tư với đối tác',
        ),
      ],
    );
  }

  Widget _buildFundItem(String name, String amount, IconData icon, Color color,
      String members, String description) {
    return GestureDetector(
      onTap: () {
        _navigateToScreen(
          FundDetail(
            name: name,
            amount: amount,
            color: color,
            description: description,
            members: [
              Member(
                name: 'Nguyễn Văn A',
                email: 'nguyenvana@gmail.com',
                avatar: 'https://i.pravatar.cc/150?img=1',
                status: 'Đã tham gia',
                history: ['Tạo quỹ', 'Thêm thành viên'],
              ),
              Member(
                name: 'Trần Thị B',
                email: 'tranthib@gmail.com',
                avatar: 'https://i.pravatar.cc/150?img=2',
                status: 'Đã tham gia',
                history: ['Tham gia quỹ'],
              ),
              // Thêm các thành viên khác
            ],
            wallets: [
              Wallet(
                name: 'Tiền mặt',
                amount: '12,500,000',
                icon: Icons.money,
                color: const Color(0xFF00C48C),
                description: 'Nguồn tiền mặt',
              ),
              Wallet(
                name: 'Ngân hàng',
                amount: '35,820,000',
                icon: Icons.account_balance,
                color: const Color(0xFF4E73F8),
                description: 'Tài khoản VCB',
              ),
              Wallet(
                name: 'Momo',
                amount: '6,000,000',
                icon: Icons.account_balance_wallet,
                color: const Color(0xFFFF6B6B),
                description: 'Ví điện tử',
              ),
            ],
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
                  '$amount đ',
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

  const AddFundDrawer({
    super.key,
    required this.color,
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
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
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

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Handle form submission
      Navigator.pop(context);
    }
  }
}
