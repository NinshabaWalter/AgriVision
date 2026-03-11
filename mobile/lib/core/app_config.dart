import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Agricultural Platform';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  // Allow override at runtime for physical devices (e.g., iPad) using --dart-define
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: kDebugMode
        ? 'http://127.0.0.1:8000/api/v1' // Default for simulators/macOS/web
        : 'https://api.agriplatform.com/api/v1',
  );

  // WebSocket base URL for real-time features
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: kDebugMode
        ? 'ws://127.0.0.1:8000/ws'
        : 'wss://api.agriplatform.com/ws',
  );
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String offlineDataKey = 'offline_data';
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = !kDebugMode;
  static const bool enableCrashReporting = !kDebugMode;
  
  // ML Model Configuration
  static const String diseaseModelPath = 'assets/ml_models/disease_detection.tflite';
  static const String diseaseLabelsPath = 'assets/ml_models/disease_labels.txt';
  
  // Image Configuration
  static const int maxImageSize = 2048; // pixels
  static const int imageQuality = 85; // 0-100
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
  
  // Offline Configuration
  static const int maxOfflineDataAge = 7; // days
  static const int syncRetryAttempts = 3;
  static const int syncRetryDelay = 5; // seconds
  
  // Location Configuration
  static const double locationAccuracy = 100; // meters
  static const int locationTimeout = 30; // seconds
  
  // Notification Configuration
  static const String notificationChannelId = 'agri_platform_notifications';
  static const String notificationChannelName = 'Agricultural Platform';
  static const String notificationChannelDescription = 'Notifications from Agricultural Platform';
  
  static Future<void> init() async {
    // Initialize app configuration
    debugPrint('Initializing app configuration...');
    
    // Load any remote configuration
    // This could fetch feature flags, API endpoints, etc.
    
    debugPrint('App configuration initialized');
  }
  
  static bool get isProduction => !kDebugMode;
  static bool get isDevelopment => kDebugMode;
}