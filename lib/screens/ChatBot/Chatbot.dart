import 'dart:ui';
import 'dart:math' show sin, pi;

import 'package:flutter/material.dart';
import 'package:uniko/config/app_config.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/core/storage_service.dart';
import '../../config/theme.config.dart';
import '../../services/chat_service.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? html;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.html,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late AnimationController _sendButtonController;
  late AnimationController _typeIndicatorController;
  late AnimationController _drawerController;
  bool _isDrawerOpen = false;
  late final ChatService _chatService;
  bool _isTyping = false;
  late AnimationController _transactionsDrawerController;
  bool _isTransactionsDrawerOpen = false;
  List<Transaction> _currentTransactions = [];
  bool _isInitialized = false;

  final List<QuickAction> _quickActions = [
    QuickAction(
      icon: Icons.add_chart,
      title: 'Ăn sáng 200k, xe 100k, điện thoại 100k',
      description: 'Ghi chép các khoản chi tiêu một cách nhanh chóng',
      gradient: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    ),
    QuickAction(
      icon: Icons.analytics_outlined,
      title: 'Thống kê tài chính của tôi tháng này',
      description: 'Xem báo cáo chi tiết về thu chi trong tháng',
      gradient: [Color(0xFF2196F3), Color(0xFF1976D2)],
    ),
    QuickAction(
      icon: Icons.savings_outlined,
      title: 'Tư vấn tiết kiệm',
      description: 'Nhận lời khuyên về cách tiết kiệm hiệu quả',
      gradient: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    ),
    QuickAction(
      icon: Icons.trending_up,
      title: 'Phân tích xu hướng chi tiêu',
      description: 'Xem xu hướng chi tiêu và đề xuất cải thiện',
      gradient: [Color(0xFFFF9800), Color(0xFFF57C00)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _typeIndicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Tin nhắn chào mừng
    _messages.add(
      ChatMessage(
        text:
            'Xin chào! Tôi là trợ lý tài chính của bạn. Tôi có thể giúp gì cho bạn?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _transactionsDrawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Debug log
    print('ChatBot URL: ${AppConfig.chatbotUrl}/chat');

    _initializeChatService();
  }

  Future<void> _initializeChatService() async {
    final token = await StorageService.getAccessToken();
    if (token == null || token.isEmpty) {
      LoggerService.error('No access token found');
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    if (mounted) {
      setState(() {
        _chatService = ChatService(token: token);
        _isInitialized = true;
      });
    }
  }

  void _handleSubmit(String text) {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đang khởi tạo, vui lòng thử lại sau')),
      );
      return;
    }

    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
      _currentTransactions = [];
    });

    _messageController.clear();
    _scrollToBottom();

    // Sử dụng ChatService
    _chatService.listenToChatStream(
      text,
      onMessage: (response) {
        if (mounted) {
          LoggerService.debug('Bot response: $response'); // Debug log
          setState(() {
            _messages.add(
              ChatMessage(
                text: response, // Thay đổi từ '' sang response
                html: response, // Giữ nguyên HTML content
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
            _isTyping = false; // Tắt typing indicator
          });
          _scrollToBottom();
        }
      },
      onRecent: (recent) {
        if (mounted && recent.isNotEmpty) {
          setState(() {
            _messages.add(
              ChatMessage(
                text: recent,
                html: recent,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        }
      },
      onTransactions: (transactions) {
        if (mounted) {
          setState(() {
            _currentTransactions = transactions;
          });
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isTyping = false;
            _messages.add(
              ChatMessage(
                text: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại sau.',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        }
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      if (_isDrawerOpen) {
        _drawerController.forward();
      } else {
        _drawerController.reverse();
      }
    });
  }

  void _toggleTransactionsDrawer() {
    setState(() {
      _isTransactionsDrawerOpen = !_isTransactionsDrawerOpen;
      if (_isTransactionsDrawerOpen) {
        _transactionsDrawerController.forward();
      } else {
        _transactionsDrawerController.reverse();
      }
    });
  }

  Widget _buildQuickActionsDrawer() {
    return AnimatedBuilder(
      animation: _drawerController,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => _isDrawerOpen ? _toggleDrawer() : null,
            child: Container(
              color: _isDrawerOpen
                  ? Colors.black.withOpacity(0.3 * _drawerController.value)
                  : Colors.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _drawerController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: _isDrawerOpen ? _buildDrawerContent() : const SizedBox.shrink(),
    );
  }

  Widget _buildDrawerContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.isDarkMode
                ? Colors.white.withOpacity(0.03)
                : Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Improved handle with subtle gradient
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.2),
                    AppTheme.primary.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title with icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bolt_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tác vụ nhanh',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Quick actions with improved design
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _quickActions.length,
              itemBuilder: (context, index) {
                final action = _quickActions[index];
                return _buildQuickActionItem(action, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(QuickAction action, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _toggleDrawer();
            _messageController.text = action.title;
            _handleSubmit(action.title);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container with gradient
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        action.gradient[0].withOpacity(0.8),
                        action.gradient[1],
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: action.gradient[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    action.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Text content with improved typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.description,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Animated arrow
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 200 + (index * 100)),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(8 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppTheme.textSecondary,
                          size: 16,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsDrawer() {
    return AnimatedBuilder(
      animation: _transactionsDrawerController,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () =>
                _isTransactionsDrawerOpen ? _toggleTransactionsDrawer() : null,
            child: Container(
              color: _isTransactionsDrawerOpen
                  ? Colors.black
                      .withOpacity(0.3 * _transactionsDrawerController.value)
                  : Colors.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _transactionsDrawerController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: _isTransactionsDrawerOpen
          ? _buildTransactionsDrawerContent()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTransactionsDrawerContent() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: AppTheme.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle and Title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.2),
                        AppTheme.primary.withOpacity(0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Chi tiết giao dịch',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentTransactions.length} giao dịch',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _currentTransactions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.isDarkMode
                              ? Colors.grey[850]!.withOpacity(0.5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowColor.withOpacity(0.05),
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
                                gradient: LinearGradient(
                                  colors: transaction.type == 'EXPENSE'
                                      ? [
                                          Colors.red.shade400,
                                          Colors.red.shade600
                                        ]
                                      : [
                                          Colors.green.shade400,
                                          Colors.green.shade600
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (transaction.type == 'EXPENSE'
                                            ? Colors.red
                                            : Colors.green)
                                        .withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                transaction.type == 'EXPENSE'
                                    ? Icons.remove_circle_outline
                                    : Icons.add_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.description,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        color: AppTheme.textSecondary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        transaction.categoryName,
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${transaction.type == 'EXPENSE' ? '-' : '+'}${NumberFormat('#,###').format(transaction.amount)}đ',
                                  style: TextStyle(
                                    color: transaction.type == 'EXPENSE'
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: AppTheme.textSecondary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      transaction.walletName,
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppTheme.isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowColor.withOpacity(0.12),
                blurRadius: 25,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle and Title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withOpacity(0.2),
                            AppTheme.primary.withOpacity(0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Chi tiết giao dịch',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentTransactions.length} giao dịch',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Transactions List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _currentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _currentTransactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.isDarkMode
                                  ? Colors.grey[850]!.withOpacity(0.5)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primary.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.shadowColor.withOpacity(0.05),
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
                                    gradient: LinearGradient(
                                      colors: transaction.type == 'EXPENSE'
                                          ? [
                                              Colors.red.shade400,
                                              Colors.red.shade600
                                            ]
                                          : [
                                              Colors.green.shade400,
                                              Colors.green.shade600
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (transaction.type == 'EXPENSE'
                                                ? Colors.red
                                                : Colors.green)
                                            .withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    transaction.type == 'EXPENSE'
                                        ? Icons.remove_circle_outline
                                        : Icons.add_circle_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.description,
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.category_outlined,
                                            color: AppTheme.textSecondary,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            transaction.categoryName,
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${transaction.type == 'EXPENSE' ? '-' : '+'}${NumberFormat('#,###').format(transaction.amount)}đ',
                                      style: TextStyle(
                                        color: transaction.type == 'EXPENSE'
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          color: AppTheme.textSecondary,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          transaction.walletName,
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.primary,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary,
                    Color(0xFF6C63FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    _buildPulsingDot(),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Subtle gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.background,
                  AppTheme.background.withOpacity(0.95),
                ],
              ),
            ),
          ),

          // Messages
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 80,
                    bottom: 80,
                    left: 20,
                    right: 20,
                  ),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 48, right: 60),
                        child: _buildTypingIndicator(),
                      );
                    }

                    final message = _messages[index];
                    final showAvatar = index == 0 ||
                        _messages[index - 1].isUser != message.isUser;
                    return _buildMessage(message, isDarkMode, showAvatar);
                  },
                ),
              ),
              _buildInputField(isDarkMode),
            ],
          ),
          // Drawer overlay
          if (_isDrawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleDrawer,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          // Quick actions drawer
          _buildQuickActionsDrawer(),
          // Transactions drawer
          _buildTransactionsDrawer(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, bool isDarkMode, bool showAvatar) {
    // Kiểm tra xem đây có phải là message cuối cùng không
    final isLastMessage = _messages.last == message;

    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: message.isUser ? 60 : (showAvatar ? 0 : 48),
        right: message.isUser ? (showAvatar ? 0 : 48) : 60,
      ),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser && showAvatar) ...[
            _buildBotAvatar(),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primary
                    : (isDarkMode ? Colors.grey[850] : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(
                      message.isUser ? 20 : (showAvatar ? 5 : 20)),
                  bottomRight: Radius.circular(
                      message.isUser ? (showAvatar ? 5 : 20) : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.html != null && message.html!.isNotEmpty)
                    Html(
                      data: message.html!,
                      style: {
                        "div": Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        ".message": Style(
                          margin: Margins.only(bottom: 8),
                          color: AppTheme.textPrimary,
                          fontSize: FontSize(14),
                          fontWeight: FontWeight.w600,
                        ),
                      },
                    )
                  else
                    Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : AppTheme.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  // Sửa điều kiện hiển thị button transactions
                  if (!message.isUser &&
                      isLastMessage &&
                      _currentTransactions.isNotEmpty) ...[
                    // Thay đổi điều kiện này
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _showTransactionsBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              color: AppTheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Xem ${_currentTransactions.length} giao dịch',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser && showAvatar) ...[
            const SizedBox(width: 12),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy_outlined,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_outline,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildInputField(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAnimatedIconButton(
            icon: Icons.grid_view_rounded,
            onPressed: _toggleDrawer,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn của bạn...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                ),
                border: InputBorder.none,
              ),
              maxLines: 5,
              minLines: 1,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
            onPressed: () => _handleSubmit(_messageController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: AppTheme.primary,
        size: 24,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bot Avatar với hiệu ứng pulse và ripple
          AnimatedBuilder(
            animation: _typeIndicatorController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.8),
                      AppTheme.primary.withOpacity(0.6 + 0.2 * sin(_typeIndicatorController.value * pi)),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.2 + 0.1 * sin(_typeIndicatorController.value * pi)),
                      blurRadius: 8 + 4 * sin(_typeIndicatorController.value * pi),
                      spreadRadius: 1 + sin(_typeIndicatorController.value * pi),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.white.withOpacity(0.9 + 0.1 * sin(_typeIndicatorController.value * pi)),
                      size: 20,
                    ),
                    // Ripple effect
                    ...List.generate(2, (index) {
                      final delay = index * pi / 2;
                      return Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                0.2 * (1 - sin((_typeIndicatorController.value * pi * 2) + delay)),
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // Animated dots với hiệu ứng wave
          Row(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedBuilder(
                  animation: _typeIndicatorController,
                  builder: (context, child) {
                    final delay = index * 0.3;
                    final wave = sin((_typeIndicatorController.value * pi * 2) - delay);
                    final scale = 0.8 + (0.4 * wave);
                    final yOffset = wave * 4;
                    
                    return Transform.translate(
                      offset: Offset(0, yOffset),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.primary.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3 * scale),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot() {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.6 * (value as double)),
                blurRadius: 4,
                spreadRadius: 2 * value,
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    _typeIndicatorController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _drawerController.dispose();
    _transactionsDrawerController.dispose();
    super.dispose();
  }
}

// Custom Pattern Painter
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.03)
      ..strokeWidth = 1;

    for (var i = 0; i < size.width; i += 20) {
      for (var j = 0; j < size.height; j += 20) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Quick Action Model
class QuickAction {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  QuickAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
