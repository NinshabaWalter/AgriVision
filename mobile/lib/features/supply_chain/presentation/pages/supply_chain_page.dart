import 'package:flutter/material.dart';

class SupplyChainPage extends StatelessWidget {
  const SupplyChainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supply Chain'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.local_shipping, size: 64, color: Colors.indigo),
            const SizedBox(height: 16),
            const Text(
              'Supply Chain Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your products from farm to market',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildSupplyChainStep(
                    stepNumber: 1,
                    title: 'Production',
                    description: 'Track crop production and harvest',
                    icon: Icons.agriculture,
                    isCompleted: false,
                  ),
                  _buildSupplyChainStep(
                    stepNumber: 2,
                    title: 'Processing',
                    description: 'Monitor processing and packaging',
                    icon: Icons.factory,
                    isCompleted: false,
                  ),
                  _buildSupplyChainStep(
                    stepNumber: 3,
                    title: 'Storage',
                    description: 'Manage inventory and storage',
                    icon: Icons.warehouse,
                    isCompleted: false,
                  ),
                  _buildSupplyChainStep(
                    stepNumber: 4,
                    title: 'Distribution',
                    description: 'Track shipments and delivery',
                    icon: Icons.local_shipping,
                    isCompleted: false,
                  ),
                  _buildSupplyChainStep(
                    stepNumber: 5,
                    title: 'Retail',
                    description: 'Monitor market sales',
                    icon: Icons.store,
                    isCompleted: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyChainStep({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required bool isCompleted,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isCompleted ? Colors.green : Colors.grey.shade300,
              child: Text(
                stepNumber.toString(),
                style: TextStyle(
                  color: isCompleted ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              color: Colors.indigo,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}