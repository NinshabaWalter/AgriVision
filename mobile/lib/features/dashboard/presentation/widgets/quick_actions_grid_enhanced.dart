import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class QuickActionsGridEnhanced extends StatelessWidget {
  const QuickActionsGridEnhanced({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Disease Detection',
        'subtitle': 'Scan crop photos',
        'icon': Icons.camera_alt,
        'color': Colors.red,
        'route': '/disease-detection',
      },
      {
        'title': 'Voice Assistant',
        'subtitle': 'Ask questions',
        'icon': Icons.mic,
        'color': Colors.blue,
        'route': '/voice-assistant',
      },
      {
        'title': 'Market Prices',
        'subtitle': 'Check latest rates',
        'icon': Icons.trending_up,
        'color': Colors.green,
        'route': '/market',
      },
      {
        'title': 'Weather Forecast',
        'subtitle': '7-day outlook',
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
        'route': '/weather',
      },
      {
        'title': 'Loan Application',
        'subtitle': 'Apply for credit',
        'icon': Icons.account_balance,
        'color': Colors.purple,
        'route': '/finance',
      },
      {
        'title': 'SMS Alerts',
        'subtitle': 'Offline updates',
        'icon': Icons.sms,
        'color': Colors.indigo,
        'route': '/sms-alerts',
      },
      {
        'title': 'Farm Records',
        'subtitle': 'Track activities',
        'icon': Icons.assignment,
        'color': Colors.brown,
        'route': '/farm-records',
      },
      {
        'title': 'Expert Consultation',
        'subtitle': 'Get professional advice',
        'icon': Icons.support_agent,
        'color': Colors.teal,
        'route': '/experts',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.getResponsiveGridCount(context, small: 2, medium: 3, large: 4),
            childAspectRatio: ResponsiveUtils.isSmallScreen(context) ? 1.3 : 1.5,
            crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context),
            mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context),
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              context,
              action['title'] as String,
              action['subtitle'] as String,
              action['icon'] as IconData,
              action['color'] as Color,
              action['route'] as String,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToRoute(context, route),
        child: Container(
          padding: ResponsiveUtils.getResponsivePadding(context, small: 12, medium: 16, large: 20),
          decoration: BoxDecoration(
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: ResponsiveUtils.getResponsiveIconSize(context, small: 20, medium: 24, large: 28),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 14, medium: 16, large: 18),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: ResponsiveUtils.isSmallScreen(context) ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, small: 2, medium: 4, large: 6)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 10, medium: 12, large: 14),
                  color: Colors.grey.shade600,
                ),
                maxLines: ResponsiveUtils.isSmallScreen(context) ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    try {
      Navigator.pushNamed(context, route);
    } catch (e) {
      // Fallback for routes that don't exist yet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening $route feature...'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}