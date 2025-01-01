import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ChatResponse {
  final String type;
  final String messages;
  final String recent;
  final bool done;
  final List<Transaction> transactions;
  final Map<String, dynamic> statistics;

  ChatResponse({
    required this.type,
    required this.messages,
    required this.recent,
    required this.done,
    required this.transactions,
    required this.statistics,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      type: json['type'] ?? '',
      messages: json['messages'] ?? '',
      recent: json['recent'] ?? '',
      done: json['done'] ?? false,
      transactions: (json['transactions'] as List?)
          ?.map((e) => Transaction.fromJson(e))
          .toList() ?? [],
      statistics: json['statistics'] as Map<String, dynamic>? ?? {},
    );
  }
}

class Transaction {
  final String item;
  final int amount;
  final Category category;
  final String type;
  final Wallet wallet;

  Transaction({
    required this.item,
    required this.amount,
    required this.category,
    required this.type,
    required this.wallet,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      item: json['item'] ?? '',
      amount: json['amount'] ?? 0,
      category: Category.fromJson(json['category'] ?? {}),
      type: json['type'] ?? '',
      wallet: Wallet.fromJson(json['wallet'] ?? {}),
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

  Future<Stream<Map<String, dynamic>>> streamChat(String message) async {
    try {
      final url = Uri.parse(_baseUrl);
      print('Calling API: ${url.toString()}'); // Debug log

      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      // Thêm headers khác nếu cần
      // request.headers['Authorization'] = 'Bearer $token';

      request.body = jsonEncode({'content': message, 'stream': true});

      final client = http.Client();
      final response = await client.send(request);

      if (response.statusCode == 200) {
        return response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .where((line) => line.isNotEmpty)
            .map((line) {
          try {
            if (line.startsWith('data: ')) {
              line = line.substring(6);
            }
            return jsonDecode(line) as Map<String, dynamic>;
          } catch (e) {
            print('Error parsing JSON: $line');
            throw Exception('Invalid response format');
          }
        });
      } else {
        print('API Error: Status ${response.statusCode}');
        print('Response headers: ${response.headers}');
        // Đọc response body để debug
        final body = await response.stream.transform(utf8.decoder).join();
        print('Response body: $body');

        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('ChatService Error: $e');
      rethrow; // Ném lại lỗi để xử lý ở UI
    }
  }

  void listenToChatStream(
    String message, {
    required Function(String) onMessage,
    required Function(String) onRecent,
    required Function(List<Transaction>) onTransactions,
    Function()? onDone,
    Function(dynamic)? onError,
  }) async {
    try {
      final stream = await streamChat(message);
      await for (final data in stream) {
        try {
          final response = ChatResponse.fromJson(data);
          
          if (response.type == 'message') {
            onMessage(response.messages);
            if (response.recent.isNotEmpty) {
              onRecent(response.recent);
            }
            if (response.transactions.isNotEmpty) {
              onTransactions(response.transactions);
            }
          }
          
          if (response.done) {
            onDone?.call();
            break;
          }
        } catch (e) {
          print('Error processing message: $e');
          onError?.call(e);
        }
      }
    } catch (e) {
      print('listenToChatStream error: $e');
      onError?.call(e);
    }
  }
}
