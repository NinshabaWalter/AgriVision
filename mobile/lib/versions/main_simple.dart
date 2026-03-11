import 'package:flutter/material.dart';

void main() {
  runApp(const AgriculturalPlatformApp());
}

class AgriculturalPlatformApp extends StatelessWidget {
  const AgriculturalPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agricultural Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agricultural Intelligence Platform'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Icon(
              Icons.agriculture,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Agricultural Intelligence Platform',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Empowering East African farmers with AI-powered solutions',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            FeatureCard(
              icon: Icons.camera_alt,
              title: 'Disease Detection',
              description: 'AI-powered crop disease identification',
            ),
            SizedBox(height: 15),
            FeatureCard(
              icon: Icons.cloud,
              title: 'Weather Predictions',
              description: 'Hyper-local weather data and alerts',
            ),
            SizedBox(height: 15),
            FeatureCard(
              icon: Icons.trending_up,
              title: 'Market Intelligence',
              description: 'Real-time crop prices and market insights',
            ),
            SizedBox(height: 15),
            FeatureCard(
              icon: Icons.analytics,
              title: 'Advanced Analytics',
              description: 'Comprehensive reporting and data insights',
            ),
            SizedBox(height: 15),
            FeatureCard(
              icon: Icons.people,
              title: 'Social Networking',
              description: 'Connect with farmers and agricultural experts',
            ),
            SizedBox(height: 15),
            FeatureCard(
              icon: Icons.account_balance,
              title: 'Financial Services',
              description: 'Microfinance, insurance, and payment solutions',
            ),
            SizedBox(height: 15),
            FeatureCard(
              icon: Icons.sensors,
              title: 'IoT Integration',
              description: 'Smart sensor monitoring and automation',
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.green,
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
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
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