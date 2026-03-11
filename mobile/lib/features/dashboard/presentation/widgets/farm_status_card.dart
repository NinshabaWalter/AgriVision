import 'package:flutter/material.dart';

class FarmStatusCard extends StatelessWidget {
  const FarmStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Farm Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/farms'),
                  child: const Text('Manage Farms'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFarmItem(
              context,
              'Rice Field A',
              'Flowering Stage',
              'Healthy',
              Colors.green,
              '2.5 hectares',
            ),
            const Divider(),
            _buildFarmItem(
              context,
              'Corn Field B',
              'Vegetative Stage',
              'Needs Attention',
              Colors.orange,
              '1.8 hectares',
            ),
            const Divider(),
            _buildFarmItem(
              context,
              'Wheat Field C',
              'Harvesting',
              'Ready',
              Colors.blue,
              '3.2 hectares',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmItem(
    BuildContext context,
    String farmName,
    String stage,
    String status,
    Color statusColor,
    String area,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.agriculture,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  farmName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$stage • $area',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}