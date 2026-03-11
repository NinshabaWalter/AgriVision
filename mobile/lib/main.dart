import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:firebase_core/firebase_core.dart'; // Temporarily disabled for web compilation
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/dashboard/presentation/pages/enhanced_dashboard_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (temporarily disabled for web compilation)
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   debugPrint('Firebase initialization failed: $e');
  // }
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await StorageService.init();
  
  // Initialize API service
  await ApiService.initialize();
  
  // Initialize notifications
  await NotificationService.init();
  
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
      title: 'Agricultural Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('sw', ''), // Swahili
        Locale('am', ''), // Amharic
        Locale('fr', ''), // French
      ],
      
      // Navigation
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/splash',
      
      // Global error handling and responsive design
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Allow user's text scale preference but limit extreme values
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}