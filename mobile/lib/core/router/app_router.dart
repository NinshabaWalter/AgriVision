import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/disease_detection/presentation/pages/disease_detection_page.dart';
import '../../features/disease_detection/presentation/pages/camera_page.dart';
import '../../features/disease_detection/presentation/pages/detection_history_page.dart';
import '../../features/weather/presentation/pages/weather_page.dart';
import '../../features/market/presentation/pages/market_page.dart';
import '../../features/farms/presentation/pages/farms_page.dart';
import '../../features/farms/presentation/pages/add_farm_page.dart';
import '../../features/soil/presentation/pages/soil_page.dart';
import '../../features/finance/presentation/pages/finance_page.dart';
import '../../features/supply_chain/presentation/pages/supply_chain_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/disease_detection/presentation/pages/disease_detection_page.dart';
import '../../features/disease_detection/presentation/pages/camera_page.dart';
import '../../features/disease_detection/presentation/pages/detection_history_page.dart';
import '../../features/weather/presentation/pages/weather_page.dart';
import '../../features/market/presentation/pages/market_page.dart';
import '../../features/farms/presentation/pages/farms_page.dart';
import '../../features/farms/presentation/pages/add_farm_page.dart';
import '../../features/soil/presentation/pages/soil_page.dart';
import '../../features/finance/presentation/pages/finance_page.dart';
import '../../features/supply_chain/presentation/pages/supply_chain_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/comprehensive_demo/presentation/pages/comprehensive_demo_page.dart';
import '../../features/dashboard/presentation/pages/enhanced_dashboard_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/splash':
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );

      case '/auth':
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );

      case '/enhanced-dashboard':
        return MaterialPageRoute(
          builder: (_) => const EnhancedDashboardPage(),
          settings: settings,
        );

      case '/comprehensive-demo':
        return MaterialPageRoute(
          builder: (_) => const ComprehensiveDemoPage(),
          settings: settings,
        );

      case '/disease-detection':
        return MaterialPageRoute(
          builder: (_) => const DiseaseDetectionPage(),
          settings: settings,
        );

      case '/disease-detection/camera':
        return MaterialPageRoute(
          builder: (_) => const CameraPage(),
          settings: settings,
        );

      case '/disease-detection/history':
        return MaterialPageRoute(
          builder: (_) => const DetectionHistoryPage(),
          settings: settings,
        );

      case '/weather':
        return MaterialPageRoute(
          builder: (_) => const WeatherPage(),
          settings: settings,
        );

      case '/market':
        return MaterialPageRoute(
          builder: (_) => const MarketPage(),
          settings: settings,
        );

      case '/farms':
        return MaterialPageRoute(
          builder: (_) => const FarmsPage(),
          settings: settings,
        );

      case '/farms/add':
        return MaterialPageRoute(
          builder: (_) => const AddFarmPage(),
          settings: settings,
        );

      case '/soil':
        return MaterialPageRoute(
          builder: (_) => const SoilPage(),
          settings: settings,
        );

      case '/finance':
        return MaterialPageRoute(
          builder: (_) => const FinancePage(),
          settings: settings,
        );

      case '/supply-chain':
        return MaterialPageRoute(
          builder: (_) => const SupplyChainPage(),
          settings: settings,
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Page Not Found'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Page Not Found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The page "${settings.name}" does not exist.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
                    child: const Text('Go to Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
