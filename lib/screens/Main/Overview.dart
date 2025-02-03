import 'package:flutter/material.dart';
import 'package:uniko/models/statistics.dart';
import 'package:uniko/providers/fund_provider.dart';
import 'package:uniko/services/core/toast_service.dart';
import 'package:uniko/widgets/TransactionDetailDrawer.dart';
import '../../config/theme.config.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:uniko/screens/ChatBot/Chatbot.dart';
import '../../widgets/CommonHeader.dart';
import 'package:provider/provider.dart';
import 'package:uniko/providers/statistics_provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/ClassificationDrawer.dart';
import '../../widgets/LoadingOverlay.dart';

// Thư viện socket_io_client
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Giả sử enum EUserStatus
enum EUserStatus { ACTIVE, INACTIVE }

// Giả sử model user
class UserModel {
  final String id;
  final String roleId;
  final String email;
  final String fullName;
  final EUserStatus status;

  UserModel({
    required this.id,
    required this.roleId,
    required this.email,
    required this.fullName,
    required this.status,
  });
}

// Tương tự EPaymentEvents
class EPaymentEvents {
  static const String REFETCH_STARTED = 'refetchStarted';
  static const String REFETCH_COMPLETE = 'refetchComplete';
  static const String REFETCH_FAILED = 'refetchFailed';
}

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  // Biến socket
  IO.Socket? socket;

  // Thời gian gọi socket gần nhất (để giới hạn 10s)
  DateTime? _lastRefetchTime;
  static const Duration _timeLimit = Duration(seconds: 10);

  // Biến cờ để hiển thị/hủy loading
  bool _isRefetching = false;
  bool isGetMeUserPending = false; // Giả sử để check user đang pending

  // Giả sử user login
  // Bạn có thể lấy user từ provider Auth, thay cho biến cứng này:
  UserModel? user = UserModel(
    id: '123',
    roleId: 'admin',
    email: 'john.doe@example.com',
    fullName: 'John Doe',
    status: EUserStatus.ACTIVE,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {
            _selectedIndex = _tabController.index;
          });
        }
      });

    // Khởi tạo socket
    _initSocket();
  }

  // Hàm khởi tạo và kết nối socket
  void _initSocket() {
    // Thay URL cho đúng backend
    socket = IO.io(
      'https://api.uniko.id.vn/', // ví dụ
      IO.OptionBuilder()
          .setTransports(['websocket']) // dùng websocket
          .disableAutoConnect()
          .build(),
    );

    // Mở kết nối
    socket?.connect();

    // Debug: in ra khi connect thành công
    socket?.onConnect((_) {
      debugPrint('=== Socket connected ===');
    });

    // Đăng ký lắng nghe sự kiện REFETCH_COMPLETE
    socket?.on(EPaymentEvents.REFETCH_COMPLETE, _handleRefetchComplete);

    // Đăng ký lắng nghe sự kiện REFETCH_FAILED
    socket?.on(EPaymentEvents.REFETCH_FAILED, _handleRefetchFailed);
  }

  // Hủy socket khi dispose
  @override
  void dispose() {
    // off listener
    socket?.off(EPaymentEvents.REFETCH_COMPLETE, _handleRefetchComplete);
    socket?.off(EPaymentEvents.REFETCH_FAILED, _handleRefetchFailed);

    socket?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Xử lý khi server bắn về sự kiện refetchComplete
  void _handleRefetchComplete(dynamic data) {
    debugPrint('=== Received refetchComplete: $data');
    setState(() {
      _isRefetching = false; // tắt loading
    });

    // data có thể chứa { status: '', messages: '' }
    final status = data['status'] ?? '';
    final message = data['messages'] ?? 'No messages';

    switch (status) {
      case 'NO_NEW_TRANSACTION':
        // Hiển thị toast success
        ToastService.showSuccess('Không có giao dịch mới !');
        break;

      case 'NEW_TRANSACTION':
        // Reset/unclassify/fetchStatistics => tương tự web
        _fetchStatisticsData();
        ToastService.showSuccess('Tìm thấy giao dịch mới !');
        break;

      default:
        // Lỗi chung
        ToastService.showError(message);
    }
  }

  /// Xử lý khi server bắn về sự kiện refetchFailed
  void _handleRefetchFailed(dynamic data) {
    debugPrint('=== Received refetchFailed: $data');
    setState(() {
      _isRefetching = false; // tắt loading
    });

    // data có thể là 1 string hoặc 1 object. Tuỳ backend
    final message = data is String
        ? data
        : (data['messages'] ?? 'Không thể tạo yêu cầu: lỗi không xác định');

    ToastService.showError(message);
  }

  /// Gọi API lấy số liệu thốnng kê
  void _fetchStatisticsData() {
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, 1);
    final endDay = DateTime(now.year, now.month + 1, 0);

    final fundId = context.read<FundProvider>().selectedFundId;
    if (fundId != null) {
      context.read<StatisticsProvider>().fetchStatistics(
            fundId,
            startDay,
            endDay,
          );
    }
  }

  void _switchTab(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _tabController.animateTo(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _onRefresh() async {
    _fetchStatisticsData();
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  /// Nút FAB "refresh" => emit refetchStarted lên server
  void _onRefetchTransaction() {
    // Kiểm tra giới hạn 10s
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCalled = _lastRefetchTime?.millisecondsSinceEpoch ?? 0;

    if (now - lastCalled < _timeLimit.inMilliseconds) {
      ToastService.showError("Vui lòng đợi 10s trước khi tạo yêu cầu mới!");
      return;
    }

    // Nếu user đang pending, không tiếp tục
    if (isGetMeUserPending) {
      ToastService.showError("Dữ liệu user đang được tải. Vui lòng đợi...");
      return;
    }

    // userPayload (như code web)
    if (user == null) {
      ToastService.showError("Không thể tạo yêu cầu: user không tồn tại");
      return;
    }

    final fundId = context.read<FundProvider>().selectedFundId;
    if (socket != null && fundId != null) {
      final userPayload = {
        "userId": user?.id ?? '',
        "roleId": user?.roleId ?? '',
        "email": user?.email ?? '',
        "fullName": user?.fullName ?? '',
        "status": user?.status.toString().split('.').last,
        "fundId": fundId
      };

      // Cập nhật thời gian refetch
      _lastRefetchTime = DateTime.now();

      setState(() {
        _isRefetching = true; // bật loading
      });

      // Gửi sự kiện REFETCH_STARTED + user payload
      socket?.emit(EPaymentEvents.REFETCH_STARTED, {
        'user': userPayload,
      });
    } else {
      ToastService.showError(
          "Không thể tạo yêu cầu: socket/fundId không tồn tại");
    }
  }

  String _formatAmount(num amount, bool isExpense) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${isExpense ? "-" : "+"}${formatter.format(amount)} đ';
  }

  // Xây dựng danh sách giao dịch chưa phân loại
  Widget _buildRecentTransactions() {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        final transactions =
            provider.statistics?.unclassifiedTransactions ?? [];

        if (transactions.isEmpty) {
          return Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : AppTheme.borderColor,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tất cả giao dịch đã được phân loại',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đã phân loại tất cả các giao dịch. Hãy tiếp tục duy trì thói quen tốt này nhé!',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giao dịch chưa phân loại',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${transactions.length} giao dịch',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...transactions.map((transaction) =>
                _buildUnclassifiedTransactionItem(transaction)),
          ],
        );
      },
    );
  }

  Widget _buildUnclassifiedTransactionItem(
      UnclassifiedTransaction transaction) {
    final isExpense = transaction.direction.toUpperCase() == 'EXPENSE';
    final amount = _formatAmount(transaction.amount, isExpense);

    // Chuyển UTC sang UTC+7
    final localDateTime =
        transaction.transactionDateTime.add(const Duration(hours: 7));
    final date = DateFormat('HH:mm - dd/MM/yyyy').format(localDateTime);

    return GestureDetector(
      onTap: () => _showTransactionDetail(transaction),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            // Thanh màu bên trái
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: isExpense ? AppTheme.error : const Color(0xFF34C759),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Nội dung giao dịch
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên tài khoản, ...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (transaction.toAccountNo?.trim().isEmpty ?? true)
                              ? ((transaction.accountSource?.name
                                          ?.trim()
                                          .isEmpty ??
                                      true)
                                  ? "Không xác định"
                                  : transaction.accountSource!.name!)
                              : transaction.toAccountNo!,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Số tiền
                      Text(
                        amount,
                        style: TextStyle(
                          color: isExpense
                              ? AppTheme.error
                              : const Color(0xFF34C759),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Thời gian + Thu nhập/Chi tiêu
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isExpense
                                  ? AppTheme.error
                                  : const Color(0xFF34C759))
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isExpense ? 'Chi tiêu' : 'Thu nhập',
                          style: TextStyle(
                            color: isExpense
                                ? AppTheme.error
                                : const Color(0xFF34C759),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(UnclassifiedTransaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (detailContext) => TransactionDetailDrawer(
        id: transaction.id,
        amount: _formatAmount(transaction.amount,
            transaction.direction.toUpperCase() == 'EXPENSE'),
        description: transaction.description,
        date: transaction.transactionDateTime,
        sourceAccount: transaction.accountSource?.name,
        toAccountNo: transaction.toAccountNo,
        toAccountName: transaction.toAccountName,
        toBankName: transaction.toBankName,
        isIncome: transaction.direction.toUpperCase() != 'EXPENSE',
        onClassifyPressed: () {
          showModalBottomSheet(
            context: detailContext,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (classifyContext) => ClassificationDrawer(
              transactionId: transaction.id,
              transactionType: transaction.direction.toUpperCase() != 'EXPENSE'
                  ? 'INCOME'
                  : 'EXPENSE',
              onSave: (reason, category, description) {
                // TODO: Xử lý lưu phân loại
                Navigator.pop(classifyContext);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.background,
          extendBodyBehindAppBar: true,
          appBar: const CommonHeader(title: 'Tổng quan'),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.primary,
            backgroundColor: AppTheme.cardBackground,
            edgeOffset: MediaQuery.of(context).padding.top + 50,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 50),
                  sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                ),
                // Balance Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _buildBalanceCard(),
                  ),
                ),
                // Thêm các phần khác nếu cần
                SliverToBoxAdapter(
                  child:
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                ),
                SliverToBoxAdapter(
                  child: _buildRecentTransactions(),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // FAB refresh => refetchStarted
              FloatingActionButton(
                onPressed: _isRefetching ? null : _onRefetchTransaction,
                backgroundColor: AppTheme.primary,
                child: _isRefetching
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
              ),
              const SizedBox(height: 10),
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

        // Loading Overlay
        if (_isRefetching)
          LoadingOverlay(
            message: 'Đang cập nhật dữ liệu...\nVui lòng đợi trong giây lát',
            color: AppTheme.primary,
          ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildBalanceCardSkeleton();
        }

        final balance = provider.statistics?.total.totalBalance ?? 0;
        final balanceRate = provider.statistics?.total.rate == "none"
            ? "0"
            : (provider.statistics?.total.rate ?? "0");

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: balance >= 0
                        ? [const Color(0xFF00B4DB), const Color(0xFF0083B0)]
                        : [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: balance >= 0
                          ? const Color(0xFF00B4DB).withOpacity(0.2)
                          : const Color(0xFFFF416C).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dòng trên: icon & rate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Số dư hiện tại',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                double.parse(balanceRate) >= 0
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${balanceRate}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Số tiền
                    Text(
                      '${NumberFormat('#,###', 'vi_VN').format(balance)} đ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Thời gian cập nhật
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Cập nhật ${DateFormat('HH:mm').format(_convertToVietnamTime(DateTime.now()))}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: AppTheme.divider.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              // Thu/Chi hôm nay
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Thu nhập',
                      amount: NumberFormat('#,###', 'vi_VN')
                          .format(provider.statistics?.income.totalToday ?? 0),
                      isIncome: true,
                      rate: provider.statistics?.income.rate,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppTheme.divider.withOpacity(0.5),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Chi tiêu',
                      amount: NumberFormat('#,###', 'vi_VN')
                          .format(provider.statistics?.expense.totalToday ?? 0),
                      isIncome: false,
                      rate: provider.statistics?.expense.rate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceCardSkeleton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 180,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _convertToVietnamTime(DateTime time) {
    return time.toUtc().add(const Duration(hours: 7));
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String amount,
    required bool isIncome,
    String? rate,
  }) {
    final color = isIncome ? const Color(0xFF34C759) : AppTheme.error;
    final safeRate = rate == "none" ? "0" : (rate ?? "0");

    return Column(
      crossAxisAlignment:
          isIncome ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment:
              isIncome ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (!isIncome) ...[
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            if (isIncome) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$amount đ',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        if (rate != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  double.parse(safeRate) > 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: color,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  '${safeRate}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
