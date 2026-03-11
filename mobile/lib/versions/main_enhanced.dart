import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Firebase imports - commented out for web compatibility testing
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/theme/app_theme.dart';
// import 'core/services/notification_service.dart';
// import 'core/services/storage_service.dart';
import 'features/dashboard/presentation/pages/enhanced_dashboard_page.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase - commented out for web compatibility
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   debugPrint('Firebase initialization failed: $e');
  // }
  
  // Initialize Hive for local storage - temporarily disabled
  // await Hive.initFlutter();
  // await StorageService.init();
  
  // Initialize notifications - temporarily disabled for web compatibility
  // await NotificationService.init();
  
  runApp(
    const ProviderScope(
      child: AgriculturalPlatformApp(),
    ),
  );
}

class AgriculturalPlatformApp extends ConsumerWidget {
  const AgriculturalPlatformApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AgriVision - East African Farmer Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Localization for East African languages
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('sw', ''), // Swahili - Kenya, Tanzania, Uganda
        Locale('am', ''), // Amharic - Ethiopia
        Locale('fr', ''), // French - Rwanda, Burundi, DRC
      ],
      
      // Navigation
      home: const EnhancedDashboardPage(),
      
      // Global error handling
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}