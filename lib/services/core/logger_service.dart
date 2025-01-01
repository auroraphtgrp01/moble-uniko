import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(String message) {
    _logger.d('🔍 DEBUG: $message');
  }

  static void info(String message) {
    _logger.i('ℹ️ INFO: $message');
  }

  static void warning(String message) {
    _logger.w('⚠️ WARNING: $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('❌ ERROR: $message', error: error, stackTrace: stackTrace);
  }

  static void api(String endpoint, dynamic data) {
    _logger.i('🌐 API [$endpoint]: $data');
  }
}
