class AppConfig {
  static bool _isDevMode = true;
  static bool get isDevMode => _isDevMode;

  static void toggleDevMode() {
    _isDevMode = !_isDevMode;
  }

  // Base URLs

  static const List<String> apiUrls = [
    'https://api-dev.uniko.id.vn/api',
    'https://api.uniko.id.vn/api',
  ];

  static String get apiUrl => apiUrls[_isDevMode ? 0 : 1];

  static const String chatbotUrl = 'https://bot.uniko.id.vn/chat';

  static const String appName = 'Uniko';
  static const int apiTimeOut = 30000;

  static const int cacheDuration = 7;

  // ENDPOINT

  // AUTHENTICATION
  static String get loginEndpoint => '$apiUrl/auth/login';
  static String get registerEndpoint => '$apiUrl/auth/register';
  static String get getMeEndpoint => '/users/me';

  // FUND
  static String getAccoutSourceByFundIdEndpoint(String fundId) =>
      '$apiUrl/account-sources/advanced/$fundId';

  // ACCOUNT TRACKER TRANSACTION TYPE ( CATEGORY )
  static String getAccountTrackerTransactionTypeEndpoint(String fundId) =>
      '$apiUrl/tracker-transaction-types/all/$fundId';

  // TRACKER TRANSACTIONS
  static String getTransactionByIdEndpoint(String id) => 
      '$apiUrl/tracker-transactions/get-by-id/$id';
}
