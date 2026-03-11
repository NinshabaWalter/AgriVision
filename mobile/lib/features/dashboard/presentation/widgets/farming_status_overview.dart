import 'package:flutter/material.dart';

class FarmingStatusOverview extends StatelessWidget {
  const FarmingStatusOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Farm Status Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStatusGrid(),
        const SizedBox(height: 16),
        _buildRecentActivities(),
      ],
    );
  }

  Widget _buildStatusGrid() {
    final statusItems = [
      {
        'title': 'Fields Planted',
        'value': '8/10',
        'progress': 0.8,
        'icon': Icons.agriculture,
        'color': Colors.green,
      },
      {
        'title': 'Irrigation Active',
        'value': '5/8',
        'progress': 0.625,
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
      {
        'title': 'Pest Control',
        'value': '3/8',
        'progress': 0.375,
        'icon': Icons.bug_report,
        'color': Colors.red,
      },
      {
        'title': 'Harvest Ready',
        'value': '0/8',
        'progress': 0.0,
        'icon': Icons.grass,
        'color': Colors.orange,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: statusItems.length,
      itemBuilder: (context, index) {
        final item = statusItems[index];
        return _buildStatusCard(
          item['title'] as String,
          item['value'] as String,
          item['progress'] as double,
          item['icon'] as IconData,
          item['color'] as Color,
        );
      },
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    double progress,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    final activities = [
      {
        'title': 'Fertilizer applied to Maize Field A',
        'time': '2 hours ago',
        'icon': Icons.scatter_plot,
        'color': Colors.green,
      },
      {
        'title': 'Irrigation system activated for Bean Field C',
        'time': '5 hours ago',
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
      {
        'title': 'Pest control treatment scheduled',
        'time': '1 day ago',
        'icon': Icons.schedule,
        'color': Colors.orange,
      },
      {
        'title': 'Soil pH test completed - Results normal',
        'time': '2 days ago',
        'icon': Icons.science,
        'color': Colors.purple,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Recent Activities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to activities page
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) => _buildActivityItem(
                  activity['title'] as String,
                  activity['time'] as String,
                  activity['icon'] as IconData,
                  activity['color'] as Color,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}