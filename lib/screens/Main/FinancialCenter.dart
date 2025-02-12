import 'package:flutter/material.dart';
import '../../config/theme.config.dart';
import 'package:intl/intl.dart';

class FinancialCenterPage extends StatefulWidget {
  const FinancialCenterPage({super.key});

  @override
  State<FinancialCenterPage> createState() => _FinancialCenterPageState();
}

class _FinancialCenterPageState extends State<FinancialCenterPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _isAmountVisible = false;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  String _formatAmount(num amount) {
    if (!_isAmountVisible) return '********';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} đ';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
              ? [Color(0xFF1F1D2B), Color(0xFF252836)]
              : [Color(0xFFF8F9FE), Color(0xFFFFFFFF)],
          ),
        ),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            _buildModernAppBar(isDarkMode),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeController,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    children: [
                      _buildTotalBalance(isDarkMode),
                      SizedBox(height: 25),
                      _buildModernCards(isDarkMode),
                      SizedBox(height: 30),
                      _buildQuickActions(isDarkMode),
                      SizedBox(height: 30),
                      _buildTransactionsAndAnalytics(isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _isAmountVisible = !_isAmountVisible),
        backgroundColor: AppTheme.primary,
        child: Icon(
          _isAmountVisible ? Icons.visibility_off : Icons.visibility,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildModernAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Tài chính của bạn',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isAmountVisible = !_isAmountVisible;
            });
          },
          icon: Icon(
            _isAmountVisible ? Icons.visibility : Icons.visibility_off,
            color: isDarkMode ? Colors.white70 : Colors.black87,
            size: 20,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 20),
          child: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, 
                color: isDarkMode ? Colors.white70 : Colors.black87),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBalance(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C72CB), Color(0xFF89CFF0)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6C72CB).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng tài sản',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isAmountVisible = !_isAmountVisible;
                          });
                        },
                        icon: Icon(
                          _isAmountVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '+15.3%',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: 0.7,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mục tiêu tháng',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '70%',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernCards(bool isDarkMode) {
    return Container(
      height: 140,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          _buildGlassCard(
            'Tiền mặt',
            _isAmountVisible ? '150.000.000 ₫' : '********',
            Icons.payments_outlined,
            Color(0xFF4ECDC4),
            isDarkMode,
          ),
          _buildGlassCard(
            'Ngân hàng',
            _isAmountVisible ? '2.150.000.000 ₫' : '********',
            Icons.account_balance_outlined,
            Color(0xFF6C72CB),
            isDarkMode,
          ),
          _buildGlassCard(
            'Đầu tư',
            _isAmountVisible ? '50.000.000 ₫' : '********',
            Icons.trending_up,
            Color(0xFFFF6B6B),
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(String title, String amount, IconData icon, Color color, bool isDarkMode) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAmountVisible = !_isAmountVisible;
                      });
                    },
                    child: Icon(
                      _isAmountVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thao tác nhanh',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnimatedActionButton(
                'Thu nhập',
                Icons.add_circle_outline,
                Color(0xFF4ECDC4),
                isDarkMode,
              ),
              _buildAnimatedActionButton(
                'Chi tiêu',
                Icons.remove_circle_outline,
                Color(0xFFFF6B6B),
                isDarkMode,
              ),
              _buildAnimatedActionButton(
                'Chuyển quỹ',
                Icons.swap_horiz,
                Color(0xFF6C72CB),
                isDarkMode,
              ),
              _buildAnimatedActionButton(
                'Báo cáo',
                Icons.analytics_outlined,
                Color(0xFFFFBE0B),
                isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedActionButton(String label, IconData icon, Color color, bool isDarkMode) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          TweenAnimationBuilder(
            duration: Duration(milliseconds: 200),
            tween: Tween<double>(begin: 1, end: 1),
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              );
            },
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsAndAnalytics(bool isDarkMode) {
    return Column(
      children: [
        _buildRecentTransactions(isDarkMode),
        SizedBox(height: 25),
        _buildExpenseAnalytics(isDarkMode),
      ],
    );
  }

  Widget _buildRecentTransactions(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode 
          ? Colors.white.withOpacity(0.05) 
          : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao dịch gần đây',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Xem tất cả'),
              ),
            ],
          ),
          SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                leading: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.shopping_bag, color: Colors.blue),
                ),
                title: Text(
                  'Mua sắm tại AEON Mall',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  '20/03/2024 • Shopping',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
                trailing: Text(
                  '-500.000 ₫',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseAnalytics(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích chi tiêu tháng này',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Thêm biểu đồ phân tích chi tiêu ở đây
          // Ví dụ: PieChart hoặc BarChart từ fl_chart
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
} 