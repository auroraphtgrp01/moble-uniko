import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniko/models/account_source.dart';
import 'package:uniko/providers/fund_provider.dart';
import 'package:uniko/screens/Home.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/core/toast_service.dart';
import 'package:uniko/services/expenditure_service.dart';
import 'package:uniko/widgets/CommonHeader.dart';
import 'package:uniko/widgets/EditFundDrawer.dart';
import '../../config/theme.config.dart';
import 'package:flutter/rendering.dart';
import '../../widgets/WalletsList.dart';
import '../../widgets/AddWalletDrawer.dart';
import '../../services/account_source_service.dart';
import 'package:intl/intl.dart';
import 'package:uniko/screens/SubScreen/WalletDetail.dart';
import 'package:uniko/widgets/WalletDetailDrawer.dart';
import 'package:uniko/providers/category_provider.dart';
import 'package:uniko/models/category.dart';
import 'package:uniko/widgets/AddCategoryDrawer.dart';
import 'package:uniko/widgets/EditCategoryDrawer.dart';
import 'package:uniko/widgets/Avatar.dart';

class FundDetail extends StatefulWidget {
  final String fundId;
  String name;
  final String amount;
  final Color color;
  String description;
  final List<Member> members;
  final List<Wallet> wallets;

  FundDetail({
    super.key,
    required this.fundId,
    required this.name,
    required this.amount,
    required this.color,
    required this.description,
    required this.members,
    required this.wallets,
  });

  @override
  State<FundDetail> createState() => _FundDetailState();
}

class _FundDetailState extends State<FundDetail> {
  final _accountSourceService = AccountSourceService();
  List<AccountSource> _accountSources = [];
  bool _isLoading = true;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadAccountSources();
    _loadCategories();
  }

  Future<void> _loadAccountSources() async {
    try {
      final response =
          await _accountSourceService.getAdvancedAccountSources(widget.fundId);
      setState(() {
        _accountSources = response.data;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Error loading account sources: $e');
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ToastService.showError('Không thể tải nguồn tiền');
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      if (mounted) {
        final categoryProvider =
            Provider.of<CategoryProvider>(context, listen: false);
        final customCategories =
            await categoryProvider.getCustomCategory(widget.fundId);
        setState(() {
          _categories = customCategories;
        });
      }
    } catch (e) {
      LoggerService.error('Error loading categories: $e');
      if (mounted) {
        ToastService.showError('Không thể tải danh mục');
      }
    }
  }

  Widget _buildAccountSourceItem(AccountSource source) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WalletDetail(wallet: source),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getSourceColor(source.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getSourceIcon(source.type),
                color: _getSourceColor(source.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: source.currency,
                      decimalDigits: 0,
                    ).format(source.currentAmount),
                    style: TextStyle(
                      color: _getSourceColor(source.type),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSourceColor(String type) {
    switch (type.toUpperCase()) {
      case 'WALLET':
        return const Color(0xFF00C48C);
      case 'BANKING':
        return const Color(0xFF4E73F8);
      default:
        return const Color(0xFF7F3DFF);
    }
  }

  IconData _getSourceIcon(String type) {
    switch (type.toUpperCase()) {
      case 'WALLET':
        return Icons.account_balance_wallet;
      case 'BANKING':
        return Icons.account_balance;
      default:
        return Icons.attach_money;
    }
  }

  Widget _buildSourcesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_accountSources.isEmpty) {
      return Container(
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
            Padding(
              padding: const EdgeInsets.all(24),
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
                    'Chưa có nguồn tiền nào',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppTheme.borderColor, height: 1),
            ListTile(
              onTap: () => _showAddWalletDrawer(context),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: widget.color,
                  size: 24,
                ),
              ),
              title: Text(
                'Thêm nguồn tiền',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _accountSources.length,
      itemBuilder: (context, index) =>
          _buildAccountSourceItem(_accountSources[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomHeight = bottomPadding + kBottomNavigationBarHeight + 100;

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: CommonHeader(
        title: widget.name,
        showFundSelector: false,
        showBackButton: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),
                      _isLoading ? _buildBalanceCardSkeleton() : _buildBalanceCard(),
                      const SizedBox(height: 24),
                      Text(
                        'Nguồn tiền',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isLoading ? _buildWalletsListSkeleton() : _buildWalletsList(),
                      const SizedBox(height: 24),
                      Text(
                        'Thành viên',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isLoading ? _buildMembersListSkeleton() : _buildMembersList(context, widget.members),
                      const SizedBox(height: 24),
                      Text(
                        'Danh mục',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isLoading ? _buildCategoriesListSkeleton() : _buildCategoriesList(),
                      const SizedBox(height: 120),
                      SizedBox(height: bottomHeight),
                    ]),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: bottomPadding + 16,
              child: _buildFloatingButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Tổng số dư',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.amount,
            style: TextStyle(
              color: widget.color,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.arrow_downward,
                label: 'Thu nhập',
                value: '5,000,000 đ',
                color: Colors.green,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.divider,
              ),
              _buildStatItem(
                icon: Icons.arrow_upward,
                label: 'Chi tiêu',
                value: '3,000,000 đ',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () {
            // Xử lý thêm giao dịch
          },
          backgroundColor: widget.color,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          onPressed: () => _showDeleteConfirmDialog(context),
          backgroundColor: Colors.red,
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBalanceCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItemSkeleton(),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withOpacity(0.2),
              ),
              _buildStatItemSkeleton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemSkeleton() {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletsListSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(
          3,
          (index) => Column(
            children: [
              _buildWalletItemSkeleton(),
              if (index < 2)
                Divider(color: AppTheme.borderColor, height: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersListSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(
          3,
          (index) => Column(
            children: [
              _buildMemberItemSkeleton(),
              if (index < 2)
                Divider(color: AppTheme.borderColor, height: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 160,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesListSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(
          3,
          (index) => Column(
            children: [
              _buildCategoryItemSkeleton(),
              if (index < 2)
                Divider(color: AppTheme.borderColor, height: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, List<Member> members) {
    return Container(
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
          ...members.map((member) => Column(
                children: [
                  MemberItem(member: member),
                  if (members.indexOf(member) != members.length - 1)
                    Divider(
                      color: AppTheme.borderColor,
                      height: 1,
                    ),
                ],
              )),
          Divider(color: AppTheme.borderColor, height: 1),
          ListTile(
            onTap: () => _showInviteDialog(context),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add,
                color: widget.color,
                size: 24,
              ),
            ),
            title: Text(
              'Mời thành viên',
              style: TextStyle(
                color: widget.color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mời thành viên',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Nhập email',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: AppTheme.textSecondary,
                    size: 20,
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
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final email = emailController.text.trim();
                        if (email.isEmpty) {
                          ToastService.showError('Vui lòng nhập email');
                          return;
                        }

                        await ExpenditureService().inviteParticipant(
                          fundId: widget.fundId,
                          emails: [email],
                        );
                        if (context.mounted) {
                          await Provider.of<FundProvider>(context,
                                  listen: false)
                              .refreshFunds();
                          Navigator.pop(context);
                          Navigator.pop(context, true);
                          ToastService.showSuccess(
                              'Quỹ đã được xóa thành công.');
                        }
                      } catch (e) {
                        ToastService.showError('Gửi lời mời thất bại: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Mời',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(
          color: AppTheme.borderColor,
          height: 1,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: index % 2 == 0
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                index % 2 == 0 ? Icons.arrow_downward : Icons.arrow_upward,
                color: index % 2 == 0 ? Colors.red : Colors.green,
                size: 16,
              ),
            ),
            title: Text(
              'Giao dịch ${5 - index}',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '12/03/2024',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            trailing: Text(
              index % 2 == 0 ? '-500,000 đ' : '+800,000 đ',
              style: TextStyle(
                color: index % 2 == 0 ? Colors.red : Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWalletsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_accountSources.isEmpty) {
      return Container(
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
            Padding(
              padding: const EdgeInsets.all(24),
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
                    'Chưa có nguồn tiền nào',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppTheme.borderColor, height: 1),
            ListTile(
              onTap: () => _showAddWalletDrawer(context),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: widget.color,
                  size: 24,
                ),
              ),
              title: Text(
                'Thêm nguồn tiền',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return WalletsList(
      wallets: _accountSources,
      color: widget.color,
      onAddWallet: () => _showAddWalletDrawer(context),
      onTapWallet: (accountSource) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => WalletDetailDrawer(
            wallet: accountSource,
            color: _getSourceColor(accountSource.type),
          ),
        );
      },
    );
  }

  void _showAddWalletDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWalletDrawer(
        color: AppTheme.primary,
        fundId: widget.fundId,
        onSuccess: () {
          Navigator.pop(context);
          _loadAccountSources();
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5247).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFFF5247),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Xóa quỹ',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn có chắc chắn muốn xóa quỹ này không?\nHành động này không thể hoàn tác.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await ExpenditureService().deleteFund(widget.fundId);
                          if (context.mounted) {
                            await Provider.of<FundProvider>(context,
                                    listen: false)
                                .refreshFunds();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                              (route) => false, // Xóa tất cả các route trước đó
                            );
                            ToastService.showSuccess(
                                'Quỹ đã được xóa thành công.');
                          }
                        } catch (e) {
                          ToastService.showError('Xóa quỹ thất bại: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5247),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xóa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categories.isEmpty) {
      return Container(
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có danh mục nào',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppTheme.borderColor, height: 1),
            ListTile(
              onTap: () => _showAddCategoryDialog(context),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: widget.color,
                  size: 24,
                ),
              ),
              title: Text(
                'Thêm danh mục',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
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
          ..._categories.map((category) => Column(
                children: [
                  _buildCategoryItem(category),
                  if (_categories.indexOf(category) != _categories.length - 1)
                    Divider(
                      color: AppTheme.borderColor,
                      height: 1,
                    ),
                ],
              )),
          Divider(color: AppTheme.borderColor, height: 1),
          ListTile(
            onTap: () => _showAddCategoryDialog(context),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: widget.color,
                size: 24,
              ),
            ),
            title: Text(
              'Thêm danh mục',
              style: TextStyle(
                color: widget.color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getRandomColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _getFirstEmoji(category.name) ?? '📁',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      title: Text(
        category.name,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        category.type == 'EXPENSE' ? 'Chi tiêu' : 'Thu nhập',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.more_vert,
          color: AppTheme.textSecondary,
        ),
        onPressed: () => _showCategoryOptions(context, category),
      ),
    );
  }

  String? _getFirstEmoji(String text) {
    final RegExp emojiRegex = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
    );

    final Match? match = emojiRegex.firstMatch(text);
    return match?.group(0);
  }

  Color _getRandomColor() {
    final List<Color> colors = [
      const Color(0xFF4E73F8), // Blue
      const Color(0xFF00C48C), // Green
      const Color(0xFFFF5247), // Red
      const Color(0xFFFFB74D), // Orange
      const Color(0xFF7E57C2), // Purple
      const Color(0xFF26C6DA), // Cyan
      const Color(0xFFFF7043), // Deep Orange
      const Color(0xFF66BB6A), // Light Green
    ];

    return colors[DateTime.now().microsecond % colors.length];
  }

  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategoryDrawer(
        fundIdCustom: widget.fundId,
        onSuccess: () {
          _loadCategories(); // Reload categories after adding new one
        },
      ),
    );
  }

  void _showDeleteCategoryConfirmDialog(
      BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5247).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFFF5247),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Xóa danh mục',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn có chắc chắn muốn xóa danh mục "${category.name}" không?\nHành động này không thể hoàn tác.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          Navigator.pop(context); // Đóng dialog xác nhận
                          Navigator.pop(context); // Đóng bottom sheet options

                          await Provider.of<CategoryProvider>(
                            context,
                            listen: false,
                          ).deleteCategory(
                            id: category.id,
                            fundId: widget.fundId,
                          );

                          _loadCategories(); // Refresh danh sách
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Không thể xóa danh mục: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5247),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xóa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryOptions(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getRandomColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getFirstEmoji(category.name) ?? '📁',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (category.type == 'EXPENSE'
                                    ? const Color(0xFFFF5247)
                                    : const Color(0xFF4CAF50))
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category.type == 'EXPENSE'
                                ? 'Chi tiêu'
                                : 'Thu nhập',
                            style: TextStyle(
                              color: category.type == 'EXPENSE'
                                  ? const Color(0xFFFF5247)
                                  : const Color(0xFF4CAF50),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Actions
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Chỉnh sửa danh mục',
                      sublabel: 'Cập nhật thông tin danh mục',
                      color: AppTheme.primary,
                      onTap: () {
                        Navigator.pop(context);
                        _showEditCategoryDialog(context, category);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      label: 'Xóa danh mục',
                      sublabel: 'Xóa vĩnh viễn danh mục này',
                      color: const Color(0xFFFF5247),
                      onTap: () {
                        _showDeleteCategoryConfirmDialog(context, category);
                      },
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sublabel,
                      style: TextStyle(
                        color: color.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditCategoryDrawer(
        category: category,
        fundId: widget.fundId,
        onSuccess: () {
          _loadCategories(); // Refresh categories list
        },
      ),
    );
  }
}

class Member {
  final String name;
  final String email;
  final String avatarId;
  final String status;
  final List<String> history;

  const Member({
    required this.name,
    required this.email,
    required this.avatarId,
    required this.status,
    required this.history,
  });
}

class MemberItem extends StatefulWidget {
  final Member member;

  const MemberItem({
    super.key,
    required this.member,
  });

  @override
  State<MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends State<MemberItem> {
  bool _isExpanded = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          title: widget.member.name,
          subtitle: widget.member.email,
          showArrow: true,
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.25 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary.withOpacity(0.6),
              size: 20,
            ),
          ),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(height: 0),
          secondChild: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.05),
              border: Border(
                top: BorderSide(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : AppTheme.divider,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Ngày tham gia',
                  '12/03/2024',
                  Icons.calendar_today,
                  AppTheme.primary,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Trạng thái',
                  widget.member.status,
                  widget.member.status == 'Đã tham gia'
                      ? Icons.check_circle
                      : Icons.access_time,
                  widget.member.status == 'Đã tham gia'
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  'Lịch sử thay đổi',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.member.history.map((item) => _buildHistoryItem(item)),
              ],
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    String? subtitle,
    bool showArrow = true,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? 0.7 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Avatar(
                avatarId: widget.member.avatarId,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Column(
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
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryItem(String item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.history,
              size: 16,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Wallet {
  final String name;
  final String amount;
  final IconData icon;
  final Color color;
  final String type;
  final String description;

  const Wallet({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
    required this.type,
    required this.description,
  });
}
