import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uniko/services/core/logger_service.dart';
import '../config/app_config.dart';

class ChatResponse {
  final String type;
  final String messages;
  final String recent;
  final bool done;
  final List<Transaction> transactions;
  final Map<String, dynamic> statistics;
  final String html;

  ChatResponse({
    required this.type,
    required this.messages,
    required this.recent,
    required this.done,
    required this.transactions,
    required this.statistics,
    required this.html,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      type: json['type'] ?? '',
      messages: json['messages'] ?? '',
      recent: json['recent'] ?? '',
      done: json['done'] ?? false,
      transactions: (json['transactions'] as List?)
              ?.map((e) => Transaction.fromJson(e))
              .toList() ??
          [],
      statistics: json['statistics'] as Map<String, dynamic>? ?? {},
      html: json['html'] as String,
    );
  }
}

class Transaction {
  final String description;
  final int amount;
  final String type;
  final String direction;
  final String walletName;
  final String categoryId;
  final String categoryName;
  final String accountSourceName;

  Transaction({
    required this.description,
    required this.amount,
    required this.type,
    required this.walletName,
    required this.categoryId,
    required this.categoryName,
    required this.accountSourceName,
    required this.direction,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      description: json['description'] ?? '',
      amount: json['amount'] ?? 0,
      type: json['type'] ?? '',
      walletName: json['walletName'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      accountSourceName: json['accountSourceName'] ?? '',
      direction: json['direction'] ?? '',
    );
  }
}

class Category {
  final String id;
  final String name;
  final String type;

  Category({
    required this.id,
    required this.name,
    required this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class Wallet {
  final String id;
  final String name;
  final String type;
  final String currency;
  final int currentAmount;

  Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.currentAmount,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      currency: json['currency'] ?? '',
      currentAmount: json['currentAmount'] ?? 0,
    );
  }
}

class ChatService {
  final String _baseUrl = AppConfig.chatbotUrl;
  final String _token;

  ChatService({required String token}) : _token = token;

  Future<ChatResponse> streamChat(String message) async {
    try {
      final url = Uri.parse(_baseUrl);
      LoggerService.debug('Calling API: ${url.toString()}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'message': message,
          'fundId': '1',
        }),
      );

      LoggerService.api(url.toString(), response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        LoggerService.debug('Raw Response: $responseData');

        String htmlContent = responseData['message'] ?? '';

        // Lấy transactions từ data
        final transactions = (responseData['data']?['transactions'] as List?)
                ?.map((e) => Transaction.fromJson(e))
                .toList() ??
            [];

        return ChatResponse(
          type: 'message',
          messages: htmlContent,
          recent: '',
          done: true,
          transactions: transactions, // Sử dụng danh sách transactions đã parse
          statistics: {},
          html: htmlContent,
        );
      } else {
        LoggerService.error('API Error: Status ${response.statusCode}');
        LoggerService.error('Response body: ${response.body}');
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('ChatService Error: $e');
      rethrow;
    }
  }

  Future<void> listenToChatStream(
    String message, {
    required Function(String) onMessage,
    required Function(String) onRecent,
    required Function(List<Transaction>) onTransactions,
    Function()? onDone,
    Function(dynamic)? onError,
  }) async {
    try {
      final response = await streamChat(message);

      if (response.type == 'message') {
        onMessage(response.messages);
        if (response.recent.isNotEmpty) {
          onRecent(response.recent);
        }
        if (response.transactions.isNotEmpty) {
          onTransactions(response.transactions);
        }
      }

      onDone?.call();
    } catch (e) {
      LoggerService.error('listenToChatStream error: $e');
      onError?.call(e);
    }
  }
}
