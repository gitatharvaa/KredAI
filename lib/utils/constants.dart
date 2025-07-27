// flutter_app/lib/utils/constants.dart
class AppConstants {
  // API Configuration
  // flutter_app/lib/utils/constants.dart
  static const String baseUrl = 'http://192.168.0.103:8000';
  // Change for production
  static const String apiVersion = 'v1';
  
  // API Endpoints
  static const String usersEndpoint = '/users/';
  static const String applicationsEndpoint = '/applications/';
  static const String explainEndpoint = '/explain/';
  static const String healthEndpoint = '/health';
  
  // App Configuration
  static const String appName = 'Credit Risk Assessment';
  static const String appVersion = '1.0.0';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  
  // Colors
  static const int primaryColorValue = 0xFF1976D2;
  static const int successColorValue = 0xFF4CAF50;
  static const int dangerColorValue = 0xFFF44336;
  static const int warningColorValue = 0xFFFF9800;
  
  // Risk Thresholds
  static const double lowRiskThreshold = 0.3;
  static const double mediumRiskThreshold = 0.7;
  
  // Form Validation
  static const int minAge = 18;
  static const int maxAge = 100;
  static const double minIncome = 1000.0;
  static const double maxLoanAmount = 1000000.0;
}
