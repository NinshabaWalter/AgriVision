import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/demo_feature_card.dart';

class ComprehensiveDemoPage extends ConsumerStatefulWidget {
  const ComprehensiveDemoPage({super.key});

  @override
  ConsumerState<ComprehensiveDemoPage> createState() => _ComprehensiveDemoPageState();
}

class _ComprehensiveDemoPageState extends ConsumerState<ComprehensiveDemoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriVision - East Africa Demo'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Core AI', icon: Icon(Icons.psychology)),
            Tab(text: 'Market', icon: Icon(Icons.store)),
            Tab(text: 'Finance', icon: Icon(Icons.account_balance)),
            Tab(text: 'Access', icon: Icon(Icons.accessibility)),
            Tab(text: 'Community', icon: Icon(Icons.group)),
            Tab(text: 'All Features', icon: Icon(Icons.apps)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoreIntelligenceTab(),
          _buildMarketDrivenTab(),
          _buildFinancialIntegrationTab(),
          _buildAccessibilityTab(),
          _buildCommunityTab(),
          _buildAllFeaturesTab(),
        ],
      ),
    );
  }

  Widget _buildCoreIntelligenceTab() {
    final coreFeatures = [
      {
        'title': 'Weather Prediction & Alerts',
        'description': 'Critical for rain-fed agriculture with micro-climate specific data',
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
        'features': [
          'Real-time weather monitoring',
          'Rainfall predictions with 85% accuracy',
          'Drought and flood early warnings',
          'Micro-climate analysis for specific fields',
          'Optimal planting window recommendations',
          'SMS alerts for weather emergencies'
        ],
        'status': 'Available Offline',
      },
      {
        'title': 'Crop Disease Identification',
        'description': 'AI-powered photo recognition for instant disease diagnosis',
        'icon': Icons.camera_alt,
        'color': Colors.red,
        'features': [
          'On-device AI for offline operation',
          'Identifies 25+ common East African crop diseases',
          'Treatment recommendations with local availability',
          'Disease progression tracking',
          'Epidemic outbreak alerts to community',
          'Integration with agricultural extension officers'
        ],
        'status': 'AI Model Available',
      },
      {
        'title': 'Soil Health Analysis',
        'description': 'Comprehensive soil recommendations using phone sensors',
        'icon': Icons.landscape,
        'color': Colors.brown,
        'features': [
          'Photo-based soil analysis',
          'pH and nutrient level estimation',
          'Fertilizer recommendations with cost optimization',
          'Crop rotation suggestions',
          'Soil improvement techniques',
          'Connection to soil testing laboratories'
        ],
        'status': 'Camera-Based',
      },
      {
        'title': 'Optimal Timing Intelligence',
        'description': 'AI determines best planting and harvesting times',
        'icon': Icons.schedule,
        'color': Colors.green,
        'features': [
          'Planting calendar based on weather patterns',
          'Harvest timing for maximum yield',
          'Market price prediction for timing decisions',
          'Irrigation scheduling',
          'Fertilizer application timing',
          'Pest control optimal windows'
        ],
        'status': 'Data-Driven',
      },
      {
        'title': 'Yield Forecasting',
        'description': 'Predict harvest outcomes for planning and marketing',
        'icon': Icons.trending_up,
        'color': Colors.blue,
        'features': [
          'Machine learning yield predictions',
          'Climate impact modeling',
          'Resource requirement forecasting',
          'Revenue projections',
          'Risk assessment and mitigation',
          'Seasonal planning support'
        ],
        'status': 'ML-Powered',
      },
    ];

    return _buildFeatureGrid(coreFeatures);
  }

  Widget _buildMarketDrivenTab() {
    final marketFeatures = [
      {
        'title': 'Real-Time Crop Prices',
        'description': 'Live prices from local and regional markets across East Africa',
        'icon': Icons.trending_up,
        'color': Colors.green,
        'features': [
          'Prices from major markets in Kenya, Tanzania, Uganda, Ethiopia',
          'Historical price trends and analysis',
          'Price alerts for target thresholds',
          'Seasonal price patterns',
          'Transport cost integration',
          'Quality grade price differentials'
        ],
        'status': 'Live Data',
      },
      {
        'title': 'Direct Buyer-Seller Marketplace',
        'description': 'Connect farmers directly with purchasers, cutting middlemen',
        'icon': Icons.handshake,
        'color': Colors.blue,
        'features': [
          'Verified buyer network',
          'Bulk purchase opportunities',
          'Contract farming arrangements',
          'Quality specifications matching',
          'Logistics coordination',
          'Payment protection and escrow'
        ],
        'status': 'Active Network',
      },
      {
        'title': 'Quality Grading Assistant',
        'description': 'Help farmers meet export standards and premium pricing',
        'icon': Icons.verified,
        'color': Colors.purple,
        'features': [
          'Photo-based quality assessment',
          'Export standard compliance checking',
          'Certification process guidance',
          'Premium market access',
          'Quality improvement recommendations',
          'Traceability documentation'
        ],
        'status': 'AI-Assisted',
      },
      {
        'title': 'Transportation Coordination',
        'description': 'Efficient logistics for getting crops to market',
        'icon': Icons.local_shipping,
        'color': Colors.orange,
        'features': [
          'Shared transportation opportunities',
          'Route optimization',
          'Cold storage facility connections',
          'Transport cost calculator',
          'Delivery scheduling',
          'GPS tracking for shipments'
        ],
        'status': 'Logistics Network',
      },
    ];

    return _buildFeatureGrid(marketFeatures);
  }

  Widget _buildFinancialIntegrationTab() {
    final financeFeatures = [
      {
        'title': 'Credit Scoring Based on Farm Data',
        'description': 'Use farming data to access microfinance with better rates',
        'icon': Icons.assessment,
        'color': Colors.green,
        'features': [
          'Farm data-driven credit scoring',
          'Lower interest rates (6-8% vs traditional 12-18%)',
          'Collateral-free loans based on performance',
          'Seasonal payment structures',
          'Group lending opportunities',
          'Credit history building'
        ],
        'status': 'Data Analytics',
      },
      {
        'title': 'Insurance & Claims Assistance',
        'description': 'Crop insurance recommendations and simplified claims',
        'icon': Icons.security,
        'color': Colors.blue,
        'features': [
          'Weather-indexed insurance products',
          'Satellite-based damage assessment',
          'Simplified mobile claims process',
          'Premium calculation based on risk',
          'Payout automation through mobile money',
          'Risk mitigation advice'
        ],
        'status': 'Insurance Partners',
      },
      {
        'title': 'Input Cost Optimization',
        'description': 'Connect with suppliers and optimize input costs',
        'icon': Icons.shopping_cart,
        'color': Colors.orange,
        'features': [
          'Bulk purchase group formation',
          'Input supplier verification',
          'Quality assurance for inputs',
          'Seasonal discount notifications',
          'Credit purchase arrangements',
          'Counterfeit product identification'
        ],
        'status': 'Supplier Network',
      },
      {
        'title': 'Revenue Tracking & Analysis',
        'description': 'Comprehensive profit analysis and financial planning',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'features': [
          'Automated expense tracking',
          'Revenue vs cost analysis',
          'Profit margin optimization',
          'Cash flow forecasting',
          'Tax planning assistance',
          'Financial goal setting'
        ],
        'status': 'Analytics Dashboard',
      },
    ];

    return _buildFeatureGrid(financeFeatures);
  }

  Widget _buildAccessibilityTab() {
    final accessibilityFeatures = [
      {
        'title': 'Offline Functionality',
        'description': 'Core features work without internet in rural areas',
        'icon': Icons.wifi_off,
        'color': Colors.orange,
        'features': [
          'Offline disease detection using on-device AI',
          'Cached weather data for 7 days',
          'Local data storage and sync',
          'Offline voice assistant',
          'SMS integration for critical alerts',
          'Low-bandwidth optimization'
        ],
        'status': 'Offline Ready',
      },
      {
        'title': 'Voice Commands & Audio',
        'description': 'Voice interface for low-literacy users',
        'icon': Icons.mic,
        'color': Colors.blue,
        'features': [
          'Multi-language voice recognition',
          'Audio responses in local languages',
          'Hands-free operation for field work',
          'Voice-to-text note taking',
          'Audio learning content',
          'Accessibility compliance'
        ],
        'status': 'Voice-Enabled',
      },
      {
        'title': 'SMS Integration',
        'description': 'Backup communication for basic phones',
        'icon': Icons.sms,
        'color': Colors.green,
        'features': [
          'USSD codes for feature phone access',
          'SMS alerts for critical information',
          'Two-way SMS communication',
          'Mobile money integration',
          'Emergency contact system',
          'Multi-language SMS support'
        ],
        'status': 'Universal Access',
      },
      {
        'title': 'Multi-Language Support',
        'description': 'Native language support across East Africa',
        'icon': Icons.translate,
        'color': Colors.purple,
        'features': [
          'English, Swahili, Amharic, French support',
          'Local dialect recognition',
          'Cultural context adaptation',
          'Regional terminology',
          'Audio content in native languages',
          'Visual icons for universal understanding'
        ],
        'status': '4 Languages',
      },
      {
        'title': 'Low-Bandwidth Optimization',
        'description': 'Optimized for basic smartphones and slow connections',
        'icon': Icons.signal_cellular_alt,
        'color': Colors.red,
        'features': [
          'Compressed images and data',
          'Progressive loading',
          'Adaptive quality based on connection',
          'Offline-first architecture',
          'Minimal data usage tracking',
          '2G network compatibility'
        ],
        'status': 'Optimized',
      },
    ];

    return _buildFeatureGrid(accessibilityFeatures);
  }

  Widget _buildCommunityTab() {
    final communityFeatures = [
      {
        'title': 'Farmer Knowledge Networks',
        'description': 'Connect with fellow farmers for knowledge sharing',
        'icon': Icons.group,
        'color': Colors.green,
        'features': [
          'Local farmer community groups',
          'Experience sharing forums',
          'Best practices exchange',
          'Peer-to-peer mentoring',
          'Regional farming challenges discussion',
          'Multi-language community support'
        ],
        'status': 'Active Community',
      },
      {
        'title': 'Expert Consultation Access',
        'description': 'Direct access to agricultural extension officers',
        'icon': Icons.support_agent,
        'color': Colors.blue,
        'features': [
          'Video consultations with experts',
          '24/7 agricultural helpline',
          'Government extension officer network',
          'University research collaboration',
          'Specialized disease diagnosis',
          'Free and premium consultation tiers'
        ],
        'status': 'Expert Network',
      },
      {
        'title': 'Success Stories & Case Studies',
        'description': 'Learn from local success stories',
        'icon': Icons.star,
        'color': Colors.orange,
        'features': [
          'Local farmer success stories',
          'Technique adoption case studies',
          'ROI improvement examples',
          'Regional adaptation stories',
          'Video testimonials',
          'Before/after farm transformations'
        ],
        'status': 'Inspiring Content',
      },
      {
        'title': 'Cooperative Management',
        'description': 'Tools for managing farmer groups and cooperatives',
        'icon': Icons.group_work,
        'color': Colors.purple,
        'features': [
          'Member management system',
          'Financial tracking for groups',
          'Bulk purchase coordination',
          'Meeting scheduling and notes',
          'Democratic decision making tools',
          'Resource sharing coordination'
        ],
        'status': 'Management Tools',
      },
    ];

    return _buildFeatureGrid(communityFeatures);
  }

  Widget _buildAllFeaturesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureOverview(),
          const SizedBox(height: 24),
          _buildPlatformStats(),
          const SizedBox(height: 24),
          _buildTestimonialsSection(),
          const SizedBox(height: 24),
          _buildCallToAction(),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(List<Map<String, dynamic>> features) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return DemoFeatureCard(
          title: feature['title'] as String,
          description: feature['description'] as String,
          icon: feature['icon'] as IconData,
          color: feature['color'] as Color,
          features: List<String>.from(feature['features']),
          status: feature['status'] as String,
        );
      },
    );
  }

  Widget _buildFeatureOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture, color: Theme.of(context).primaryColor, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AgriVision: Complete Agricultural Intelligence Platform',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Designed specifically for East African farmers, AgriVision combines AI-powered crop disease detection, weather predictions, market intelligence, and financial services to drive agricultural adoption and improve farmer livelihoods.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildFeatureChip('20+ AI Features', Icons.psychology, Colors.purple),
                _buildFeatureChip('4 Languages', Icons.language, Colors.blue),
                _buildFeatureChip('Offline Ready', Icons.wifi_off, Colors.orange),
                _buildFeatureChip('SMS Integration', Icons.sms, Colors.green),
                _buildFeatureChip('Expert Network', Icons.school, Colors.red),
                _buildFeatureChip('Market Access', Icons.store, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildPlatformStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Platform Impact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatItem('Disease Detection', '95% Accuracy', Icons.healing, Colors.red)),
                Expanded(child: _buildStatItem('Weather Predictions', '7 Days Forecast', Icons.wb_sunny, Colors.orange)),
                Expanded(child: _buildStatItem('Market Integration', '5 Countries', Icons.public, Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatItem('Offline Features', '80% Available', Icons.wifi_off, Colors.green)),
                Expanded(child: _buildStatItem('Languages', '4 Supported', Icons.translate, Colors.purple)),
                Expanded(child: _buildStatItem('Expert Network', '24/7 Support', Icons.support_agent, Colors.teal)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
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
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farmer Success Stories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTestimonial(
              'John Mwangi',
              'Coffee Farmer, Kiambu, Kenya',
              'AgriVision helped me increase my coffee yield by 40% using AI-powered disease detection and optimal planting times.',
              'assets/images/farmer1.jpg',
            ),
            const SizedBox(height: 12),
            _buildTestimonial(
              'Mary Wanjiku',
              'Maize Farmer, Nakuru, Kenya',
              'The voice assistant feature allows me to get farming advice even when working in the fields. It speaks Swahili!',
              'assets/images/farmer2.jpg',
            ),
            const SizedBox(height: 12),
            _buildTestimonial(
              'David Ochieng',
              'Bean Farmer, Kisumu, Kenya',
              'Direct market access through the platform helped me sell my beans at 25% higher prices.',
              'assets/images/farmer3.jpg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonial(String name, String location, String quote, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green.shade200,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  location,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '"$quote"',
                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade400,
              Colors.green.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready to Transform East African Agriculture?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Join thousands of farmers already using AgriVision to increase yields, reduce costs, and access better markets.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                    ),
                    child: const Text('Start Using AgriVision'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: const Text('Learn More'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}