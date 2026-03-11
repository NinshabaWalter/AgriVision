import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/micro_climate_data.dart';
import '../../data/models/weather_forecast.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_map_widget.dart';
import '../widgets/farming_calendar_widget.dart';
import '../widgets/weather_alert_widget.dart';

class EnhancedWeatherPage extends ConsumerStatefulWidget {
  const EnhancedWeatherPage({super.key});

  @override
  ConsumerState<EnhancedWeatherPage> createState() => _EnhancedWeatherPageState();
}

class _EnhancedWeatherPageState extends ConsumerState<EnhancedWeatherPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedLocation = 'Current Location';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherProvider.notifier).getCurrentWeather();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather & Climate'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Current', icon: Icon(Icons.wb_sunny)),
            Tab(text: 'Forecast', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Alerts', icon: Icon(Icons.warning)),
            Tab(text: 'Farm Calendar', icon: Icon(Icons.event)),
            Tab(text: 'Climate Map', icon: Icon(Icons.map)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () => _showLocationSelector(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(weatherProvider.notifier).refreshWeather(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentWeatherTab(weatherState),
          _buildForecastTab(weatherState),
          _buildAlertsTab(weatherState),
          _buildFarmCalendarTab(weatherState),
          _buildClimateMapTab(weatherState),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherTab(WeatherState weatherState) {
    if (weatherState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final current = weatherState.currentWeather;
    if (current == null) {
      return const Center(child: Text('No weather data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCurrentWeatherCard(current),
          const SizedBox(height: 16),
          _buildMicroClimateCard(weatherState.microClimateData),
          const SizedBox(height: 16),
          _buildFarmingAdviceCard(current),
          const SizedBox(height: 16),
          _buildSoilConditionsCard(current),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherCard(WeatherForecast current) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _getWeatherIcon(current.condition),
                  size: 64,
                  color: _getWeatherColor(current.condition),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${current.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        current.condition,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Feels like ${current.feelsLike.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherMetric('Humidity', '${current.humidity}%', Icons.water_drop),
                _buildWeatherMetric('Wind', '${current.windSpeed} km/h', Icons.air),
                _buildWeatherMetric('UV Index', current.uvIndex.toString(), Icons.wb_sunny),
                _buildWeatherMetric('Visibility', '${current.visibility} km', Icons.visibility),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getConditionsColor(current).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _getFarmingIcon(current),
                        color: _getConditionsColor(current),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getFarmingCondition(current),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getConditionsColor(current),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFarmingAdvice(current),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMicroClimateCard(MicroClimateData? microClimate) {
    if (microClimate == null) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.thermostat, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Micro-Climate Conditions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMicroClimateItem(
                    'Soil Temp',
                    '${microClimate.soilTemperature.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    _getSoilTempColor(microClimate.soilTemperature),
                  ),
                ),
                Expanded(
                  child: _buildMicroClimateItem(
                    'Soil Moisture',
                    '${(microClimate.soilMoisture * 100).toStringAsFixed(0)}%',
                    Icons.water,
                    _getSoilMoistureColor(microClimate.soilMoisture),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMicroClimateItem(
                    'Evapotranspiration',
                    '${microClimate.evapotranspiration.toStringAsFixed(1)} mm',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildMicroClimateItem(
                    'Growth Index',
                    microClimate.growthIndex.toStringAsFixed(1),
                    Icons.eco,
                    _getGrowthIndexColor(microClimate.growthIndex),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroClimateItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
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
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFarmingAdviceCard(WeatherForecast current) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Farming Advice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._getFarmingAdviceList(current).map((advice) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    advice['icon'] as IconData,
                    size: 16,
                    color: advice['color'] as Color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advice['text'] as String,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilConditionsCard(WeatherForecast current) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.landscape, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Field Conditions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildConditionIndicator(
              'Planting Conditions',
              _getPlantingConditions(current),
              _getPlantingConditionsColor(current),
            ),
            const SizedBox(height: 12),
            _buildConditionIndicator(
              'Spraying Window',
              _getSprayingConditions(current),
              _getSprayingConditionsColor(current),
            ),
            const SizedBox(height: 12),
            _buildConditionIndicator(
              'Harvesting Conditions',
              _getHarvestingConditions(current),
              _getHarvestingConditionsColor(current),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionIndicator(String label, String condition, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            condition,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastTab(WeatherState weatherState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _build7DayForecast(weatherState.forecast),
          const SizedBox(height: 16),
          _buildLongTermForecast(),
          const SizedBox(height: 16),
          _buildSeasonalOutlook(),
        ],
      ),
    );
  }

  Widget _build7DayForecast(List<WeatherForecast> forecast) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7-Day Forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.length,
                itemBuilder: (context, index) {
                  final day = forecast[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Text(
                          _formatDayName(day.date),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          _getWeatherIcon(day.condition),
                          size: 32,
                          color: _getWeatherColor(day.condition),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${day.maxTemp.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${day.minTemp.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (day.precipitationChance > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.water_drop,
                                size: 12,
                                color: Colors.blue.shade600,
                              ),
                              Text(
                                '${day.precipitationChance}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLongTermForecast() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Long-term Outlook (30 days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildOutlookItem(
              'Rainfall',
              'Above average expected',
              'Good for planting season crops',
              Icons.water_drop,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildOutlookItem(
              'Temperature',
              'Slightly below average',
              'Ideal for cool season vegetables',
              Icons.thermostat,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildOutlookItem(
              'Dry Spells',
              'Expected mid-month',
              'Plan irrigation accordingly',
              Icons.wb_sunny,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlookItem(
    String title,
    String forecast,
    String advice,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
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
                forecast,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                advice,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonalOutlook() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seasonal Climate Outlook',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Favorable Growing Season Ahead',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Weather patterns indicate excellent conditions for the next 3 months. Consider expanding cultivation area.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsTab(WeatherState weatherState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...weatherState.weatherAlerts.map((alert) => WeatherAlertWidget(
            alert: alert,
            onDismiss: () => ref.read(weatherProvider.notifier).dismissAlert(alert.id),
          )),
          if (weatherState.weatherAlerts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Weather Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Weather conditions are favorable for farming activities',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFarmCalendarTab(WeatherState weatherState) {
    return FarmingCalendarWidget(
      weatherData: weatherState.currentWeather,
      forecast: weatherState.forecast,
    );
  }

  Widget _buildClimateMapTab(WeatherState weatherState) {
    return WeatherMapWidget(
      currentLocation: weatherState.currentLocation,
      onLocationChanged: (location) {
        ref.read(weatherProvider.notifier).updateLocation(location);
      },
    );
  }

  // Helper methods for weather conditions and colors
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'partly cloudy':
        return Icons.wb_cloudy;
      case 'windy':
        return Icons.air;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Colors.orange;
      case 'cloudy':
      case 'overcast':
        return Colors.grey;
      case 'rainy':
      case 'rain':
        return Colors.blue;
      case 'thunderstorm':
        return Colors.purple;
      case 'partly cloudy':
        return Colors.blueGrey;
      case 'windy':
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }

  Color _getConditionsColor(WeatherForecast weather) {
    if (weather.temperature < 10 || weather.temperature > 35) return Colors.red;
    if (weather.humidity > 80 || weather.windSpeed > 25) return Colors.orange;
    return Colors.green;
  }

  IconData _getFarmingIcon(WeatherForecast weather) {
    if (weather.temperature < 10 || weather.temperature > 35) return Icons.warning;
    if (weather.humidity > 80 || weather.windSpeed > 25) return Icons.info;
    return Icons.check_circle;
  }

  String _getFarmingCondition(WeatherForecast weather) {
    if (weather.temperature < 10 || weather.temperature > 35) return 'Poor Conditions';
    if (weather.humidity > 80 || weather.windSpeed > 25) return 'Fair Conditions';
    return 'Excellent Conditions';
  }

  String _getFarmingAdvice(WeatherForecast weather) {
    if (weather.temperature < 10) return 'Too cold for most farming activities';
    if (weather.temperature > 35) return 'Avoid outdoor work during peak hours';
    if (weather.humidity > 80) return 'High humidity may increase disease risk';
    if (weather.windSpeed > 25) return 'Avoid spraying due to high winds';
    return 'Perfect conditions for all farming activities';
  }

  List<Map<String, dynamic>> _getFarmingAdviceList(WeatherForecast weather) {
    List<Map<String, dynamic>> advice = [];
    
    if (weather.precipitationChance > 60) {
      advice.add({
        'icon': Icons.umbrella,
        'text': 'Rain expected - postpone spraying activities',
        'color': Colors.blue,
      });
    }
    
    if (weather.temperature >= 18 && weather.temperature <= 28) {
      advice.add({
        'icon': Icons.agriculture,
        'text': 'Ideal temperature for planting most crops',
        'color': Colors.green,
      });
    }
    
    if (weather.windSpeed < 10) {
      advice.add({
        'icon': Icons.spray_tan,
        'text': 'Good conditions for foliar spraying',
        'color': Colors.green,
      });
    }
    
    if (weather.humidity < 70) {
      advice.add({
        'icon': Icons.water_drop,
        'text': 'Consider irrigation for young plants',
        'color': Colors.orange,
      });
    }

    return advice;
  }

  Color _getSoilTempColor(double temp) {
    if (temp < 15) return Colors.blue;
    if (temp > 30) return Colors.red;
    return Colors.green;
  }

  Color _getSoilMoistureColor(double moisture) {
    if (moisture < 0.3) return Colors.red;
    if (moisture > 0.8) return Colors.blue;
    return Colors.green;
  }

  Color _getGrowthIndexColor(double index) {
    if (index < 0.5) return Colors.red;
    if (index > 0.8) return Colors.green;
    return Colors.orange;
  }

  String _getPlantingConditions(WeatherForecast weather) {
    if (weather.soilMoisture != null && weather.soilMoisture! > 0.6) return 'Good';
    if (weather.precipitationChance > 70) return 'Wait';
    return 'Fair';
  }

  Color _getPlantingConditionsColor(WeatherForecast weather) {
    final condition = _getPlantingConditions(weather);
    switch (condition) {
      case 'Good': return Colors.green;
      case 'Wait': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _getSprayingConditions(WeatherForecast weather) {
    if (weather.windSpeed > 15) return 'Poor';
    if (weather.precipitationChance > 40) return 'Poor';
    return 'Good';
  }

  Color _getSprayingConditionsColor(WeatherForecast weather) {
    return _getSprayingConditions(weather) == 'Good' ? Colors.green : Colors.red;
  }

  String _getHarvestingConditions(WeatherForecast weather) {
    if (weather.precipitationChance > 30) return 'Wait';
    if (weather.humidity > 80) return 'Fair';
    return 'Good';
  }

  Color _getHarvestingConditionsColor(WeatherForecast weather) {
    final condition = _getHarvestingConditions(weather);
    switch (condition) {
      case 'Good': return Colors.green;
      case 'Wait': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _formatDayName(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month) return 'Today';
    if (date.day == now.add(const Duration(days: 1)).day) return 'Tomorrow';
    
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  void _showLocationSelector() {
    // TODO: Implement location selector dialog
  }
}