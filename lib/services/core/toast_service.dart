import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastService {
  // Hiển thị toast thành công
  static void showSuccess(String message) {
    _showCustomToast(
      message: message,
      backgroundColor: const Color(0xFF34C759),
      icon: Icons.check_circle_rounded,
    );
  }

  // Hiển thị toast lỗi
  static void showError(String message) {
    _showCustomToast(
      message: message,
      backgroundColor: const Color(0xFFFF3B30),
      icon: Icons.error_rounded,
    );
  }

  // Hiển thị toast cảnh báo
  static void showWarning(String message) {
    _showCustomToast(
      message: message,
      backgroundColor: const Color(0xFFFF9500),
      icon: Icons.warning_rounded,
    );
  }

  // Hiển thị toast thông tin
  static void showInfo(String message) {
    _showCustomToast(
      message: message,
      backgroundColor: const Color(0xFF007AFF),
      icon: Icons.info_rounded,
    );
  }

  static void _showCustomToast({
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // Hủy toast cũ nếu đang hiển thị
    Fluttertoast.cancel();
    
    final FToast fToast = FToast();
    
    // Tạo widget toast tùy chỉnh
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    // Hiển thị toast
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: backgroundColor.withOpacity(0.95),
      textColor: Colors.white,
      fontSize: 14.0,
      webShowClose: true,
      webBgColor: "linear-gradient(to right, ${backgroundColor.toString()}, ${backgroundColor.withOpacity(0.8).toString()})",
      webPosition: "center",
    );
  }
}
