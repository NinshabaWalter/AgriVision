import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineModePage extends ConsumerStatefulWidget {
  const OfflineModePage({super.key});

  @override
  ConsumerState<OfflineModePage> createState() => _OfflineModePageState();
}

class _OfflineModePageState extends ConsumerState<OfflineModePage> {
  bool isOfflineMode = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOfflineStatusCard(),
            const SizedBox(height: 16),
            _buildCachedDataCard(),
            const SizedBox(height: 16),
            _buildOfflineFeaturesCard(),
            const SizedBox(height: 16),
            _buildSyncOptionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOfflineMode ? Icons.wifi_off : Icons.wifi,
                  color: isOfflineMode ? Colors.orange : Colors.green,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOfflineMode ? 'Offline Mode Active' : 'Connected',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isOfflineMode ? Colors.orange : Colors.green,
                        ),
                      ),
                      Text(
                        isOfflineMode 
                          ? 'Using cached data - limited features available'
                          : 'All features available with live data',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Critical alerts will still be sent via SMS even when offline',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
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

  Widget _buildCachedDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Offline Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDataItem('Weather Forecast', '7 days cached', Icons.wb_sunny, Colors.orange),
            _buildDataItem('Market Prices', 'Last updated 2 hours ago', Icons.trending_up, Colors.green),
            _buildDataItem('Disease Detection', 'AI model available offline', Icons.camera_alt, Colors.red),
            _buildDataItem('Farm Records', 'All data synced', Icons.assignment, Colors.blue),
            _buildDataItem('Expert Advice', '50+ cached tips', Icons.school, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineFeaturesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Offline Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              'Disease Detection',
              'Take photos and get instant AI-powered disease identification',
              Icons.camera_alt,
              true,
            ),
            _buildFeatureItem(
              'Voice Assistant',
              'Ask questions and get cached agricultural advice',
              Icons.mic,
              true,
            ),
            _buildFeatureItem(
              'Farm Records',
              'Log activities and track progress offline',
              Icons.edit_note,
              true,
            ),
            _buildFeatureItem(
              'Weather Forecast',
              'View cached 7-day weather predictions',
              Icons.wb_sunny,
              true,
            ),
            _buildFeatureItem(
              'Market Prices',
              'Check last known crop prices and trends',
              Icons.trending_up,
              true,
            ),
            _buildFeatureItem(
              'Live Market Trading',
              'Requires internet connection for real-time transactions',
              Icons.swap_horiz,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon, bool available) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: available ? Colors.green : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: available ? Colors.black : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      available ? Icons.check_circle : Icons.wifi,
                      color: available ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: available ? Colors.grey : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sync Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto-sync when connected'),
              subtitle: const Text('Automatically sync data when internet is available'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Low bandwidth mode'),
              subtitle: const Text('Reduce data usage by compressing content'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('SMS backup alerts'),
              subtitle: const Text('Send critical alerts via SMS when offline'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _forceSyncData(),
                    icon: const Icon(Icons.sync),
                    label: const Text('Force Sync'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _clearCachedData(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Cache'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _forceSyncData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Syncing data... This may take a few moments'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearCachedData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cached Data'),
        content: const Text(
          'This will remove all offline data. You will need an internet connection to use most features after clearing cache.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}