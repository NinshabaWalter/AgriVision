import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Comprehensive agricultural features imports
// Note: Some features commented out for initial compilation - will be enabled after full implementation
// import '../../../voice_assistant/presentation/pages/voice_assistant_page.dart';
// import '../../../marketplace/presentation/pages/marketplace_page.dart';
// import '../../../sms_integration/presentation/pages/sms_alerts_page.dart';
// import '../../../microfinance/presentation/pages/microfinance_page.dart';
// import '../../../weather/presentation/pages/enhanced_weather_page.dart';
// import '../../../community/presentation/pages/farmer_network_page.dart';
// import '../../../yield_forecasting/presentation/pages/yield_forecast_page.dart';
import '../../../comprehensive_demo/presentation/pages/comprehensive_demo_page.dart';
import '../../../offline_capabilities/presentation/pages/offline_mode_page.dart';
import '../widgets/enhanced_dashboard_header.dart';
import '../widgets/ai_insights_card.dart';
import '../widgets/quick_actions_grid_enhanced.dart';
import '../widgets/farming_status_overview.dart';
import '../widgets/notifications_widget.dart';

class EnhancedDashboardPage extends ConsumerStatefulWidget {
  const EnhancedDashboardPage({super.key});

  @override
  ConsumerState<EnhancedDashboardPage> createState() => _EnhancedDashboardPageState();
}

class _EnhancedDashboardPageState extends ConsumerState<EnhancedDashboardPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isVoiceListening = false;

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const NavigationDestination(
      icon: Icon(Icons.wb_sunny),
      label: 'Weather',
    ),
    const NavigationDestination(
      icon: Icon(Icons.store),
      label: 'Market',
    ),
    const NavigationDestination(
      icon: Icon(Icons.trending_up),
      label: 'Forecast',
    ),
    const NavigationDestination(
      icon: Icon(Icons.account_balance),
      label: 'Finance',
    ),
    const NavigationDestination(
      icon: Icon(Icons.group),
      label: 'Community',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildPage(_selectedIndex),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildDashboard();
      case 1:
        return const OfflineModePage(); // Weather page placeholder
      case 2:
        return const ComprehensiveDemoPage(); // Marketplace placeholder 
      case 3:
        return const ComprehensiveDemoPage(); // Yield forecast placeholder
      case 4:
        return const ComprehensiveDemoPage(); // Finance placeholder
      case 5:
        return const ComprehensiveDemoPage(); // Community placeholder
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EnhancedDashboardHeader(),
            const SizedBox(height: 20),
            const NotificationsWidget(),
            const SizedBox(height: 16),
            const AIInsightsCard(),
            const SizedBox(height: 20),
            const QuickActionsGridEnhanced(),
            const SizedBox(height: 20),
            const FarmingStatusOverview(),
            const SizedBox(height: 16),
            _buildMarketSummaryCard(),
            const SizedBox(height: 16),
            _buildWeatherSummaryCard(),
            const SizedBox(height: 16),
            _buildCommunityUpdatesCard(),
            const SizedBox(height: 16),
            _buildFinancialSummaryCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Market Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _navigateToPage(2),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPriceItem('Maize', 'KES 45/kg', '+5%', Colors.green),
                ),
                Expanded(
                  child: _buildPriceItem('Beans', 'KES 150/kg', '-2%', Colors.red),
                ),
                Expanded(
                  child: _buildPriceItem('Coffee', 'KES 280/kg', '+12%', Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'European buyers seeking organic coffee - premium pricing available',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String crop, String price, String change, Color color) {
    return Column(
      children: [
        Text(
          crop,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          change,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeatherSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Weather & Farming Advice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _navigateToPage(1),
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.thermostat, size: 48, color: Colors.orange),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '25°C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Partly Cloudy',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Excellent for planting',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _buildWeatherMetric('Humidity', '65%'),
                    _buildWeatherMetric('Rain', '30%'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rain expected tomorrow - good time to plant short-season crops',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityUpdatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Community Updates',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _navigateToPage(5),
                  child: const Text('Join Discussion'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCommunityUpdate(
              'John Mwangi',
              'Shared successful maize harvest results using new hybrid seeds',
              '2 hours ago',
              Icons.agriculture,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildCommunityUpdate(
              'Agricultural Expert',
              'Coffee disease outbreak reported in Kiambu - take preventive measures',
              '4 hours ago',
              Icons.warning,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildCommunityUpdate(
              'Mary Wanjiku',
              'Looking for buyers - 50 tons of organic beans ready for sale',
              '6 hours ago',
              Icons.store,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityUpdate(
    String author,
    String content,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Financial Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _navigateToPage(4),
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialMetric(
                    'Available Credit',
                    'KES 250,000',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildFinancialMetric(
                    'Savings Balance',
                    'KES 125,000',
                    Icons.savings,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialMetric(
                    'Insurance Coverage',
                    '5 hectares',
                    Icons.security,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildFinancialMetric(
                    'Credit Score',
                    '785/850',
                    Icons.assessment,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Good credit score - eligible for premium loan products with 6% interest',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => _navigateToPage(index),
      destinations: _destinations,
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "voice",
          onPressed: _toggleVoiceAssistant,
          backgroundColor: _isVoiceListening ? Colors.red : Colors.green,
          child: Icon(
            _isVoiceListening ? Icons.mic : Icons.mic_none,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "sms",
          onPressed: _openSmsAlerts,
          backgroundColor: Colors.blue,
          mini: true,
          child: const Icon(Icons.sms, color: Colors.white),
        ),
      ],
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleVoiceAssistant() {
    if (_isVoiceListening) {
      setState(() {
        _isVoiceListening = false;
      });
    } else {
      // TODO: Navigate to voice assistant when implemented
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ComprehensiveDemoPage(),
        ),
      );
    }
  }

  void _openSmsAlerts() {
    // TODO: Navigate to SMS alerts when implemented
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OfflineModePage(),
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 2));
    // TODO: Refresh all dashboard data from providers
  }
}