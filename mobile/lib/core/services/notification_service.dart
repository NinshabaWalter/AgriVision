import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart'; // Temporarily disabled for web compilation
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../app_config.dart';
import 'storage_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  // static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance; // Temporarily disabled

  static Future<void> init() async {
    if (!AppConfig.enablePushNotifications) return;

    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Initialize Firebase messaging (temporarily disabled for web compilation)
    // await _initializeFirebaseMessaging();
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _createNotificationChannel();
    }
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      description: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Firebase messaging temporarily disabled for web compilation
  /*
  static Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await StorageService.setString('fcm_token', token);
      debugPrint('FCM Token: $token');
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      StorageService.setString('fcm_token', token);
      // TODO: Send token to backend
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }
  */

  static Future<void> requestPermissions() async {
    // Request notification permission
    final notificationStatus = await Permission.notification.request();
    
    if (notificationStatus.isGranted) {
      debugPrint('Notification permission granted');
    } else {
      debugPrint('Notification permission denied');
    }

    // Request location permission for weather alerts
    final locationStatus = await Permission.location.request();
    
    if (locationStatus.isGranted) {
      debugPrint('Location permission granted');
    } else {
      debugPrint('Location permission denied');
    }
  }

  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    Priority priority = Priority.defaultPriority,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  static Future<void> showWeatherAlert({
    required String title,
    required String message,
    required String severity,
  }) async {
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    
    await showLocalNotification(
      id: id,
      title: '🌤️ $title',
      body: message,
      payload: 'weather_alert:$severity',
      priority: severity == 'high' || severity == 'extreme' 
          ? Priority.max 
          : Priority.high,
    );
  }

  static Future<void> showDiseaseAlert({
    required String cropName,
    required String diseaseName,
    required double confidence,
  }) async {
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    
    await showLocalNotification(
      id: id,
      title: '🔍 Disease Detected',
      body: '$diseaseName detected in $cropName (${(confidence * 100).toInt()}% confidence)',
      payload: 'disease_detection:$diseaseName',
      priority: Priority.high,
    );
  }

  static Future<void> showMarketAlert({
    required String cropName,
    required double price,
    required String trend,
  }) async {
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    
    final trendEmoji = trend == 'rising' ? '📈' : trend == 'falling' ? '📉' : '📊';
    
    await showLocalNotification(
      id: id,
      title: '$trendEmoji Market Update',
      body: '$cropName price: \$${price.toStringAsFixed(2)} ($trend)',
      payload: 'market_update:$cropName',
      priority: Priority.defaultPriority,
    );
  }

  static Future<void> showReminderNotification({
    required String title,
    required String message,
    required DateTime scheduledTime,
  }) async {
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    
    await _localNotifications.zonedSchedule(
      id,
      title,
      message,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConfig.notificationChannelId,
          AppConfig.notificationChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  // Firebase message handlers temporarily disabled for web compilation
  /*
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');
    
    // Show local notification for foreground messages
    if (message.notification != null) {
      await showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'Agricultural Platform',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Received background message: ${message.messageId}');
    // Handle background message processing
  }

  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    
    // Navigate to appropriate screen based on message data
    final data = message.data;
    if (data.containsKey('type')) {
      _handleNotificationPayload('${data['type']}:${data['id'] ?? ''}');
    }
  }
  */

  static void _handleNotificationPayload(String payload) {
    debugPrint('Handling notification payload: $payload');
    
    final parts = payload.split(':');
    if (parts.length >= 2) {
      final type = parts[0];
      final id = parts[1];
      
      switch (type) {
        case 'weather_alert':
          // Navigate to weather screen
          break;
        case 'disease_detection':
          // Navigate to disease detection screen
          break;
        case 'market_update':
          // Navigate to market screen
          break;
        default:
          // Navigate to dashboard
          break;
      }
    }
  }

  static Future<String?> getFCMToken() async {
    return await StorageService.getString('fcm_token');
  }

  static Future<bool> areNotificationsEnabled() async {
    // Firebase messaging temporarily disabled - return local notification status
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}

// Firebase background message handler temporarily disabled for web compilation
/*
// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await NotificationService._handleBackgroundMessage(message);
}
*/