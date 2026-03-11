import 'package:flutter/material.dart';

class SoilPage extends StatelessWidget {
  const SoilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Analysis'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.terrain, size: 64, color: Colors.brown),
            const SizedBox(height: 16),
            const Text(
              'Soil Analysis',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Monitor and analyze your soil health',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    icon: Icons.water_drop,
                    title: 'Moisture Level',
                    subtitle: 'Coming Soon',
                    color: Colors.blue,
                  ),
                  _buildFeatureCard(
                    icon: Icons.science,
                    title: 'pH Level',
                    subtitle: 'Coming Soon',
                    color: Colors.green,
                  ),
                  _buildFeatureCard(
                    icon: Icons.eco,
                    title: 'Nutrients',
                    subtitle: 'Coming Soon',
                    color: Colors.orange,
                  ),
                  _buildFeatureCard(
                    icon: Icons.thermostat,
                    title: 'Temperature',
                    subtitle: 'Coming Soon',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}