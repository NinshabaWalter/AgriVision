import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/pages/enhanced_dashboard_page.dart';
import 'features/disease_detection/presentation/pages/disease_detection_page.dart';
import 'features/voice_assistant/presentation/pages/voice_assistant_page.dart';
import 'features/market/presentation/pages/market_page.dart';
import 'features/weather/presentation/pages/weather_page.dart';
import 'features/finance/presentation/pages/finance_page.dart';
import 'features/sms_integration/presentation/pages/sms_alerts_page.dart';
import 'features/farms/presentation/pages/farm_records_page.dart';
import 'features/community/presentation/pages/expert_consultation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      title: 'AgriVision - Complete East African Farmer Platform',
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
      routes: {
        '/disease-detection': (context) => const DiseaseDetectionPage(),
        '/voice-assistant': (context) => const VoiceAssistantPage(),
        '/market': (context) => const MarketPage(),
        '/weather': (context) => const WeatherPage(),
        '/finance': (context) => const FinancePage(),
        '/sms-alerts': (context) => const SmsAlertsPage(),
        '/farm-records': (context) => const FarmRecordsPage(),
        '/experts': (context) => const ExpertConsultationPage(),
      },
      
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