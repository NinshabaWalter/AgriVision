import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/responsive_utils.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRegion = 'Kenya';
  String _selectedTimeframe = '7 Days';

  final List<String> _regions = ['Kenya', 'Tanzania', 'Uganda', 'Ethiopia', 'Rwanda'];
  final List<String> _timeframes = ['24 Hours', '7 Days', '30 Days', '3 Months'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Market Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showPriceAlerts,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: ResponsiveUtils.isSmallScreen(context),
          tabs: [
            Tab(
              text: ResponsiveUtils.isSmallScreen(context) ? 'Prices' : 'Prices', 
              icon: const Icon(Icons.trending_up),
            ),
            Tab(
              text: ResponsiveUtils.isSmallScreen(context) ? 'Charts' : 'Charts', 
              icon: const Icon(Icons.show_chart),
            ),
            Tab(
              text: ResponsiveUtils.isSmallScreen(context) ? 'Buyers' : 'Buyers', 
              icon: const Icon(Icons.handshake),
            ),
            Tab(
              text: ResponsiveUtils.isSmallScreen(context) ? 'Alerts' : 'Alerts', 
              icon: const Icon(Icons.notifications_active),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPricesTab(),
                _buildChartsTab(),
                _buildBuyersTab(),
                _buildAlertsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSellDialog,
        icon: const Icon(Icons.sell),
        label: const Text('Sell Crops'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: const InputDecoration(
                labelText: 'Region',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _regions.map((region) => DropdownMenuItem(
                value: region,
                child: Text(region),
              )).toList(),
              onChanged: (value) => setState(() => _selectedRegion = value!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedTimeframe,
              decoration: const InputDecoration(
                labelText: 'Timeframe',
                prefixIcon: Icon(Icons.schedule),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _timeframes.map((timeframe) => DropdownMenuItem(
                value: timeframe,
                child: Text(timeframe),
              )).toList(),
              onChanged: (value) => setState(() => _selectedTimeframe = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricesTab() {
    final crops = _getCropPrices();
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          return _buildPriceCard(crop);
        },
      ),
    );
  }

  Widget _buildPriceCard(Map<String, dynamic> crop) {
    final isPositive = crop['change'] > 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCropDetails(crop),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: crop['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  crop['icon'],
                  color: crop['color'],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop['name'],
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 16, medium: 18, large: 20),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${crop['unit']} • ${crop['market']}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 10, medium: 12, large: 14),
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'KES ${crop['price']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: changeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(changeIcon, color: changeColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${crop['change'].abs()}%',
                                style: TextStyle(
                                  color: changeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'High: KES ${crop['high']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Low: KES ${crop['low']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _setAlert(crop['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Alert', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Trends',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        'KES ${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        'Day ${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateChartData(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildMarketInsights(),
        ],
      ),
    );
  }

  Widget _buildBuyersTab() {
    final buyers = _getBuyers();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: buyers.length,
      itemBuilder: (context, index) {
        final buyer = buyers[index];
        return _buildBuyerCard(buyer);
      },
    );
  }

  Widget _buildBuyerCard(Map<String, dynamic> buyer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    buyer['name'][0],
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buyer['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        buyer['company'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRatingColor(buyer['rating']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: _getRatingColor(buyer['rating']),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        buyer['rating'].toString(),
                        style: TextStyle(
                          color: _getRatingColor(buyer['rating']),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Looking for: ${buyer['crops'].join(', ')}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Quantity: ${buyer['quantity']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Price: KES ${buyer['price']}/kg',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactBuyer(buyer),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Contact'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makeDeal(buyer),
                    icon: const Icon(Icons.handshake, size: 16),
                    label: const Text('Make Deal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Alerts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set Price Alerts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Get notified when crop prices reach your target levels.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _createAlert,
                    icon: const Icon(Icons.add_alert),
                    label: const Text('Create Alert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Active Alerts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                _buildAlertItem('Maize', 'Above KES 50/kg', true),
                _buildAlertItem('Coffee', 'Below KES 250/kg', false),
                _buildAlertItem('Beans', 'Above KES 140/kg', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String crop, String condition, bool isActive) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.notifications,
          color: isActive ? Colors.green : Colors.grey,
        ),
        title: Text(crop),
        subtitle: Text(condition),
        trailing: Switch(
          value: isActive,
          onChanged: (value) => _toggleAlert(crop, value),
          activeColor: Colors.green,
        ),
      ),
    );
  }

  Widget _buildMarketInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              'Seasonal Trend',
              'Maize prices typically rise 20% during dry season (June-August)',
              Icons.trending_up,
              Colors.blue,
            ),
            _buildInsightItem(
              'Export Opportunity',
              'European buyers seeking organic coffee - premium pricing available',
              Icons.flight_takeoff,
              Colors.green,
            ),
            _buildInsightItem(
              'Weather Impact',
              'Expected rains may reduce prices by 10-15% next month',
              Icons.cloud_queue,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, IconData icon, Color color) {
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
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

  List<Map<String, dynamic>> _getCropPrices() {
    return [
      {
        'name': 'Maize',
        'price': 45,
        'change': 5.2,
        'high': 48,
        'low': 42,
        'unit': 'per kg',
        'market': 'Nairobi',
        'icon': Icons.grain,
        'color': Colors.amber,
      },
      {
        'name': 'Coffee',
        'price': 280,
        'change': 12.5,
        'high': 295,
        'low': 265,
        'unit': 'per kg',
        'market': 'Mombasa',
        'icon': Icons.coffee,
        'color': Colors.brown,
      },
      {
        'name': 'Beans',
        'price': 150,
        'change': -2.1,
        'high': 155,
        'low': 145,
        'unit': 'per kg',
        'market': 'Kisumu',
        'icon': Icons.eco,
        'color': Colors.green,
      },
      {
        'name': 'Tea',
        'price': 320,
        'change': 8.7,
        'high': 335,
        'low': 310,
        'unit': 'per kg',
        'market': 'Kericho',
        'icon': Icons.local_cafe,
        'color': Colors.green.shade700,
      },
      {
        'name': 'Rice',
        'price': 85,
        'change': -1.5,
        'high': 88,
        'low': 82,
        'unit': 'per kg',
        'market': 'Mwea',
        'icon': Icons.rice_bowl,
        'color': Colors.orange,
      },
    ];
  }

  List<Map<String, dynamic>> _getBuyers() {
    return [
      {
        'name': 'John Kamau',
        'company': 'East Africa Exports Ltd',
        'rating': 4.8,
        'crops': ['Coffee', 'Tea'],
        'quantity': '500+ tons',
        'price': 285,
      },
      {
        'name': 'Sarah Wanjiku',
        'company': 'Premium Grains Co.',
        'rating': 4.6,
        'crops': ['Maize', 'Beans'],
        'quantity': '200+ tons',
        'price': 47,
      },
      {
        'name': 'Ahmed Hassan',
        'company': 'Coastal Trading',
        'rating': 4.9,
        'crops': ['Rice', 'Maize'],
        'quantity': '1000+ tons',
        'price': 87,
      },
    ];
  }

  List<FlSpot> _generateChartData() {
    return [
      const FlSpot(1, 42),
      const FlSpot(2, 44),
      const FlSpot(3, 43),
      const FlSpot(4, 46),
      const FlSpot(5, 45),
      const FlSpot(6, 47),
      const FlSpot(7, 45),
    ];
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.orange;
    return Colors.red;
  }

  Future<void> _refreshData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Market data refreshed'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showPriceAlerts() {
    _tabController.animateTo(3);
  }

  void _showSellDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sell Your Crops'),
        content: const Text('Connect with verified buyers and get the best prices for your harvest.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to sell page
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showCropDetails(Map<String, dynamic> crop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${crop['name']} Details',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Current Price: KES ${crop['price']}/${crop['unit']}'),
              Text('24h Change: ${crop['change']}%'),
              Text('Market: ${crop['market']}'),
              // Add more details here
            ],
          ),
        ),
      ),
    );
  }

  void _setAlert(String cropName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Price alert set for $cropName'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _contactBuyer(Map<String, dynamic> buyer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contacting ${buyer['name']}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _makeDeal(Map<String, dynamic> buyer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Initiating deal with ${buyer['name']}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert creation dialog would open here'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleAlert(String crop, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert for $crop ${value ? 'enabled' : 'disabled'}'),
        backgroundColor: value ? Colors.green : Colors.grey,
      ),
    );
  }
}