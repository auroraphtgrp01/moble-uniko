class AppConfig {
  // Base URLs
  static const String apiUrl = 'https://api.uniko.id.vn/api';
  static const String chatbotUrl = 'https://bot.uniko.id.vn/chat/stream';

  static const String appName = 'Uniko';
  static const int apiTimeOut = 30000;

  static const int cacheDuration = 7;

  // ENDPOINT

  // AUTHENTICATION
  static const String loginEndpoint = '$apiUrl/auth/login';
  static const String registerEndpoint = '$apiUrl/auth/register';
}
