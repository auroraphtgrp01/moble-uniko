import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uniko/models/account_source.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/core/toast_service.dart';
import '../../config/theme.config.dart';
import 'package:flutter/rendering.dart';
import '../../widgets/WalletsList.dart';
import '../../widgets/AddWalletDrawer.dart';
import '../../services/account_source_service.dart';
import 'package:intl/intl.dart';

class FundDetail extends StatefulWidget {
  final String fundId;
  final String name;
  final String amount;
  final Color color;
  final String description;
  final List<Member> members;
  final List<Wallet> wallets;

  const FundDetail({
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

  @override
  void initState() {
    super.initState();
    _loadAccountSources();
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
      setState(() => _isLoading = false);
      if (mounted) {
        ToastService.showError('Không thể tải nguồn tiền');
      }
    }
  }

  Widget _buildAccountSourceItem(AccountSource source) {
    return Container(
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

  // Trong TabBarView, thêm tab Nguồn Tiền
  Widget _buildSourcesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_accountSources.isEmpty) {
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
              'Chưa có nguồn tiền nào',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.background.withOpacity(0.7),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            widget.name,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Thêm logic refresh data
          await Future.delayed(const Duration(milliseconds: 1500));
        },
        color: AppTheme.primary,
        backgroundColor: AppTheme.cardBackground,
        edgeOffset: MediaQuery.of(context).padding.top + 80,
        child: CustomScrollView(
          slivers: [
            // Thêm padding cho content
            SliverPadding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 70),
              sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fund Balance Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Số dư quỹ',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.amount} đ',
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(
                                'Thu',
                                '+2,500,000 đ',
                                Icons.arrow_upward,
                                Colors.green,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: AppTheme.borderColor,
                              ),
                              _buildStatItem(
                                'Chi',
                                '-1,800,000 đ',
                                Icons.arrow_downward,
                                Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Thêm phần Nguồn Tiền
                    Text(
                      'Nguồn tiền',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWalletsList(),

                    const SizedBox(height: 24),

                    // Members Section
                    Text(
                      'Thành viên',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMembersList(context, widget.members),

                    const SizedBox(height: 24),

                    // Recent Transactions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Giao dịch gần đây',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to all transactions
                          },
                          child: Text(
                            'Xem tất cả',
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
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
            fontSize: 13,
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
          ...members
              .map((member) => Column(
                    children: [
                      MemberItem(member: member),
                      if (members.indexOf(member) != members.length - 1)
                        Divider(
                          color: AppTheme.borderColor,
                          height: 1,
                        ),
                    ],
                  ))
              .toList(),
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
                    onPressed: () {
                      // TODO: Handle invite
                      Navigator.pop(context);
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
              'Chưa có nguồn tiền nào',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final wallets = _accountSources
        .map((source) => Wallet(
              name: source.name,
              amount: NumberFormat.currency(
                locale: 'vi_VN',
                symbol: source.currency,
                decimalDigits: 0,
              ).format(source.currentAmount),
              icon: _getSourceIcon(source.type),
              color: _getSourceColor(source.type),
              description: source.type,
            ))
        .toList();

    return WalletsList(
      wallets: wallets,
      color: widget.color,
      onAddWallet: _showAddWalletDrawer,
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
}

class Member {
  final String name;
  final String email;
  final String avatar;
  final String status;
  final List<String> history;

  const Member({
    required this.name,
    required this.email,
    required this.avatar,
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
          icon: Icons.person_outline_rounded,
          iconColor: AppTheme.primary,
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
                ...widget.member.history
                    .map((item) => _buildHistoryItem(item))
                    .toList(),
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
    required IconData icon,
    required String title,
    String? subtitle,
    bool showArrow = true,
    Widget? trailing,
    required VoidCallback onTap,
    Color? iconColor,
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
              CircleAvatar(
                backgroundImage: NetworkImage(widget.member.avatar),
                radius: 20,
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
  final String description;

  const Wallet({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
    required this.description,
  });
}
