import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastService {
  // Hiển thị toast thành công
  static void showSuccess(String message) {
    _showToast(
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  // Hiển thị toast lỗi
  static void showError(String message) {
    _showToast(
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  // Hiển thị toast cảnh báo
  static void showWarning(String message) {
    _showToast(
      message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  // Hiển thị toast thông tin
  static void showInfo(String message) {
    _showToast(
      message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  static void _showToast(
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: backgroundColor.withOpacity(0.9),
      textColor: Colors.white,
      fontSize: 16.0,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      webShowClose: true,
      webBgColor:
          "linear-gradient(to right, ${backgroundColor.toString()}, ${backgroundColor.withOpacity(0.8).toString()})",
      webPosition: "center",
    );
  }
}
