import 'dart:ui';

import 'package:flutter/material.dart';
import '../config/theme.config.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late AnimationController _sendButtonController;
  late AnimationController _typeIndicatorController;
  late AnimationController _drawerController;
  bool _isDrawerOpen = false;

  final List<QuickAction> _quickActions = [
    QuickAction(
      icon: Icons.add_chart,
      title: 'Ghi chép chi tiêu nhanh giúp tôi',
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
      duration: const Duration(milliseconds: 600),
    )..repeat();
    
    // Tin nhắn chào mừng
    _messages.add(
      ChatMessage(
        text: 'Xin chào! Tôi là trợ lý tài chính của bạn. Tôi có thể giúp gì cho bạn?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();

    // Giả lập phản hồi của bot sau 1 giây
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Đây là phản hồi mẫu cho tin nhắn của bạn.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
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
        color: AppTheme.isDarkMode 
            ? Colors.grey[900] 
            : Colors.white,
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
              color: AppTheme.isDarkMode 
                  ? Colors.grey[850] 
                  : Colors.white,
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

  @override
  Widget build(BuildContext context) {
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
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
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
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, bool isDarkMode, bool showAvatar) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: message.isUser ? 60 : showAvatar ? 0 : 48,
        right: message.isUser ? showAvatar ? 0 : 48 : 60,
      ),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
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
                    : (isDarkMode 
                        ? Colors.grey[850] 
                        : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(
                    message.isUser ? 20 : showAvatar ? 5 : 20),
                  bottomRight: Radius.circular(
                    message.isUser ? showAvatar ? 5 : 20 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser 
                      ? Colors.white 
                      : AppTheme.textPrimary,
                  fontSize: 15,
                ),
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
    return AnimatedBuilder(
      animation: _typeIndicatorController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: List.generate(3, (index) {
              final animation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _typeIndicatorController,
                  curve: Interval(
                    index * 0.2,
                    0.6 + index * 0.2,
                    curve: Curves.easeInOut,
                  ),
                ),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.translate(
                  offset: Offset(0, -2 * animation.value),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
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