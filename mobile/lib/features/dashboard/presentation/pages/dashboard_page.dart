import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/weather_summary_card.dart';
import '../widgets/recent_detections_card.dart';
import '../widgets/market_prices_card.dart';
import '../widgets/farm_status_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _selectedIndex == 0 ? _buildDashboard() : _buildOtherPages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Farms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Detect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),
            const SizedBox(height: 20),
            const QuickActionsGrid(),
            const SizedBox(height: 20),
            const WeatherSummaryCard(),
            const SizedBox(height: 16),
            const RecentDetectionsCard(),
            const SizedBox(height: 16),
            const MarketPricesCard(),
            const SizedBox(height: 16),
            const FarmStatusCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherPages() {
    switch (_selectedIndex) {
      case 1:
        return _buildPlaceholderPage('Farms', Icons.local_florist, '/farms');
      case 2:
        return _buildPlaceholderPage('Disease Detection', Icons.camera_alt, '/disease-detection');
      case 3:
        return _buildPlaceholderPage('Market', Icons.trending_up, '/market');
      case 4:
        return _buildPlaceholderPage('Profile', Icons.person, '/profile');
      default:
        return _buildDashboard();
    }
  }

  Widget _buildPlaceholderPage(String title, IconData icon, String route) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Feature coming soon!'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, route),
            child: Text('Go to $title'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Refresh dashboard data
  }
}