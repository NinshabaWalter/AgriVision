import 'package:flutter/material.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLocation = 'Nairobi, Kenya';
  
  final List<String> _locations = [
    'Nairobi, Kenya',
    'Mombasa, Kenya',
    'Kisumu, Kenya',
    'Dar es Salaam, Tanzania',
    'Kampala, Uganda',
    'Addis Ababa, Ethiopia',
  ];

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
        title: const Text('Weather & Farming Advice'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _showLocationPicker,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWeather,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Today', icon: Icon(Icons.today)),
            Tab(text: '7-Day', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'Farming', icon: Icon(Icons.agriculture)),
            Tab(text: 'Alerts', icon: Icon(Icons.warning)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildWeeklyTab(),
          _buildFarmingTab(),
          _buildAlertsTab(),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return RefreshIndicator(
      onRefresh: _refreshWeather,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationHeader(),
            const SizedBox(height: 20),
            _buildCurrentWeatherCard(),
            const SizedBox(height: 20),
            _buildHourlyForecast(),
            const SizedBox(height: 20),
            _buildWeatherDetails(),
            const SizedBox(height: 20),
            _buildFarmingRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.blue.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _selectedLocation,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          'Updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '25°C',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Partly Cloudy',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Feels like 28°C',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.wb_cloudy,
                  size: 80,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherMetric('High', '29°C', Icons.keyboard_arrow_up),
                _buildWeatherMetric('Low', '18°C', Icons.keyboard_arrow_down),
                _buildWeatherMetric('Rain', '30%', Icons.water_drop),
                _buildWeatherMetric('Wind', '12 km/h', Icons.air),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    final hours = _getHourlyForecast();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hourly Forecast',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hours.length,
            itemBuilder: (context, index) {
              final hour = hours[index];
              return _buildHourlyItem(hour);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyItem(Map<String, dynamic> hour) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Text(
            hour['time'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            hour['icon'],
            color: Colors.blue.shade600,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            '${hour['temp']}°',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${hour['rain']}%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem('Humidity', '65%', Icons.water_drop, Colors.blue),
                ),
                Expanded(
                  child: _buildDetailItem('UV Index', '7 High', Icons.wb_sunny, Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem('Pressure', '1013 hPa', Icons.speed, Colors.purple),
                ),
                Expanded(
                  child: _buildDetailItem('Visibility', '10 km', Icons.visibility, Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmingRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Farming Advice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              'Excellent conditions for planting',
              'Temperature and humidity are ideal for seed germination',
              Icons.eco,
              Colors.green,
            ),
            _buildRecommendationItem(
              'Good time for irrigation',
              'Low rainfall probability - consider watering crops',
              Icons.water_drop,
              Colors.blue,
            ),
            _buildRecommendationItem(
              'UV protection recommended',
              'High UV index - protect sensitive crops',
              Icons.wb_sunny,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description, IconData icon, Color color) {
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

  Widget _buildWeeklyTab() {
    final days = _getWeeklyForecast();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        return _buildDayCard(day);
      },
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                day['day'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              day['icon'],
              color: Colors.blue.shade600,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day['condition'],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Rain: ${day['rain']}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${day['high']}°',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${day['low']}°',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFarmingCalendar(),
          const SizedBox(height: 20),
          _buildCropSpecificAdvice(),
          const SizedBox(height: 20),
          _buildSeasonalTips(),
        ],
      ),
    );
  }

  Widget _buildFarmingCalendar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Week\'s Farming Calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCalendarItem('Monday', 'Plant maize - optimal soil moisture', Icons.eco, Colors.green),
            _buildCalendarItem('Wednesday', 'Apply fertilizer to coffee plants', Icons.scatter_plot, Colors.brown),
            _buildCalendarItem('Friday', 'Harvest beans - dry conditions expected', Icons.agriculture, Colors.orange),
            _buildCalendarItem('Sunday', 'Prepare land for next planting season', Icons.landscape, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarItem(String day, String activity, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activity,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropSpecificAdvice() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crop-Specific Weather Advice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCropAdviceItem(
              'Maize',
              'Current conditions are excellent for growth. Expect 15% yield increase.',
              Icons.grain,
              Colors.amber,
              'Excellent',
            ),
            _buildCropAdviceItem(
              'Coffee',
              'Moderate rainfall needed. Consider supplemental irrigation.',
              Icons.coffee,
              Colors.brown,
              'Good',
            ),
            _buildCropAdviceItem(
              'Beans',
              'High humidity may increase disease risk. Monitor closely.',
              Icons.eco,
              Colors.green,
              'Caution',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropAdviceItem(String crop, String advice, IconData icon, Color color, String status) {
    Color statusColor;
    switch (status) {
      case 'Excellent':
        statusColor = Colors.green;
        break;
      case 'Good':
        statusColor = Colors.blue;
        break;
      case 'Caution':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      crop,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
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

  Widget _buildSeasonalTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seasonal Farming Tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              'Dry Season Preparation',
              'Install drip irrigation systems to conserve water during upcoming dry months.',
              Icons.water_drop,
              Colors.blue,
            ),
            _buildTipItem(
              'Pest Management',
              'Warm weather increases pest activity. Apply organic pesticides preventively.',
              Icons.bug_report,
              Colors.red,
            ),
            _buildTipItem(
              'Soil Health',
              'Add organic matter to improve soil water retention for dry season.',
              Icons.landscape,
              Colors.brown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description, IconData icon, Color color) {
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

  Widget _buildAlertsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weather Alerts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAlertCard(
            'Heavy Rain Warning',
            'Expected heavy rainfall tomorrow. Secure loose materials and avoid field work.',
            Icons.warning,
            Colors.orange,
            'Active',
          ),
          _buildAlertCard(
            'Drought Watch',
            'Below-average rainfall expected next month. Prepare water conservation measures.',
            Icons.water_drop_outlined,
            Colors.red,
            'Watch',
          ),
          _buildAlertCard(
            'Frost Advisory',
            'Temperatures may drop below 5°C this weekend. Protect sensitive crops.',
            Icons.ac_unit,
            Colors.blue,
            'Advisory',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String title, String description, IconData icon, Color color, String level) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          level,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
      ),
    );
  }

  List<Map<String, dynamic>> _getHourlyForecast() {
    return [
      {'time': '12 PM', 'temp': 25, 'rain': 10, 'icon': Icons.wb_sunny},
      {'time': '1 PM', 'temp': 27, 'rain': 15, 'icon': Icons.wb_cloudy},
      {'time': '2 PM', 'temp': 28, 'rain': 20, 'icon': Icons.wb_cloudy},
      {'time': '3 PM', 'temp': 29, 'rain': 30, 'icon': Icons.cloud},
      {'time': '4 PM', 'temp': 27, 'rain': 45, 'icon': Icons.cloud},
      {'time': '5 PM', 'temp': 25, 'rain': 60, 'icon': Icons.grain},
    ];
  }

  List<Map<String, dynamic>> _getWeeklyForecast() {
    return [
      {'day': 'Today', 'condition': 'Partly Cloudy', 'high': 29, 'low': 18, 'rain': 30, 'icon': Icons.wb_cloudy},
      {'day': 'Tomorrow', 'condition': 'Rainy', 'high': 24, 'low': 16, 'rain': 80, 'icon': Icons.grain},
      {'day': 'Wednesday', 'condition': 'Sunny', 'high': 31, 'low': 19, 'rain': 5, 'icon': Icons.wb_sunny},
      {'day': 'Thursday', 'condition': 'Partly Cloudy', 'high': 28, 'low': 17, 'rain': 25, 'icon': Icons.wb_cloudy},
      {'day': 'Friday', 'condition': 'Cloudy', 'high': 26, 'low': 15, 'rain': 40, 'icon': Icons.cloud},
      {'day': 'Saturday', 'condition': 'Sunny', 'high': 30, 'low': 18, 'rain': 10, 'icon': Icons.wb_sunny},
      {'day': 'Sunday', 'condition': 'Thunderstorms', 'high': 25, 'low': 16, 'rain': 90, 'icon': Icons.thunderstorm},
    ];
  }

  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _locations.length,
            itemBuilder: (context, index) {
              final location = _locations[index];
              return ListTile(
                title: Text(location),
                leading: Icon(
                  Icons.location_on,
                  color: location == _selectedLocation ? Colors.blue : Colors.grey,
                ),
                onTap: () {
                  setState(() => _selectedLocation = location);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refreshWeather() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weather data refreshed'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}