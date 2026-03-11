import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/yield_forecast.dart';
import '../../data/models/farming_data.dart';
import '../providers/yield_forecast_provider.dart';
import '../widgets/yield_prediction_card.dart';
import '../widgets/farming_calendar_widget.dart';

class YieldForecastPage extends ConsumerStatefulWidget {
  const YieldForecastPage({super.key});

  @override
  ConsumerState<YieldForecastPage> createState() => _YieldForecastPageState();
}

class _YieldForecastPageState extends ConsumerState<YieldForecastPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCrop = 'Maize';
  String selectedSeason = 'Current Season';

  final List<String> crops = ['Maize', 'Beans', 'Coffee', 'Tea', 'Rice', 'Wheat'];
  final List<String> seasons = ['Current Season', 'Next Season', 'Long Rains', 'Short Rains'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(yieldForecastProvider.notifier).loadForecastData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forecastState = ref.watch(yieldForecastProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yield Forecasting'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Predictions', icon: Icon(Icons.trending_up)),
            Tab(text: 'Planning', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
            Tab(text: 'Reports', icon: Icon(Icons.assessment)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(yieldForecastProvider.notifier).refreshForecast(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCropAndSeasonSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPredictionsTab(forecastState),
                _buildPlanningTab(forecastState),
                _buildAnalyticsTab(forecastState),
                _buildReportsTab(forecastState),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addFarmingData(),
        icon: const Icon(Icons.add_chart),
        label: const Text('Add Data'),
      ),
    );
  }

  Widget _buildCropAndSeasonSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              value: selectedCrop,
              decoration: const InputDecoration(
                labelText: 'Crop Type',
                prefixIcon: Icon(Icons.agriculture),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: crops.map((crop) {
                return DropdownMenuItem(
                  value: crop,
                  child: Text(crop),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedCrop = value!);
                _updateForecast();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedSeason,
              decoration: const InputDecoration(
                labelText: 'Season',
                prefixIcon: Icon(Icons.calendar_month),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: seasons.map((season) {
                return DropdownMenuItem(
                  value: season,
                  child: Text(season),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedSeason = value!);
                _updateForecast();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsTab(YieldForecastState forecastState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCurrentForecastCard(forecastState.currentForecast),
          const SizedBox(height: 16),
          _buildForecastComparisonCard(forecastState),
          const SizedBox(height: 16),
          _buildRiskAssessmentCard(forecastState.riskFactors),
          const SizedBox(height: 16),
          _buildOptimizationSuggestionsCard(forecastState.optimizationTips),
        ],
      ),
    );
  }

  Widget _buildCurrentForecastCard(YieldForecast? forecast) {
    if (forecast == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.trending_up,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No forecast data available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add farming data to generate yield predictions',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _addFarmingData(),
                child: const Text('Add Farming Data'),
              ),
            ],
          ),
        ),
      );
    }

    return YieldPredictionCard(forecast: forecast);
  }

  Widget _buildForecastComparisonCard(YieldForecastState forecastState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Yield Comparison',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 3500,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['This\nSeason', 'Last\nSeason', 'Average', 'Target'];
                          if (value.toInt() >= 0 && value.toInt() < titles.length) {
                            return Text(titles[value.toInt()], style: const TextStyle(fontSize: 12));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 2800, color: Colors.green)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 2450, color: Colors.blue)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2600, color: Colors.orange)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 3000, color: Colors.purple)]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildComparisonMetric('This Season', '2,800 kg/ha', Colors.green),
                _buildComparisonMetric('Last Season', '2,450 kg/ha', Colors.blue),
                _buildComparisonMetric('Average', '2,600 kg/ha', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonMetric(String label, String value, Color color) {
    return Column(
      children: [
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
        ),
      ],
    );
  }

  Widget _buildRiskAssessmentCard(List<RiskFactor> riskFactors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Risk Assessment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (riskFactors.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Low Risk - Conditions are favorable for good yields',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...riskFactors.map((risk) => _buildRiskItem(risk)),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskItem(RiskFactor risk) {
    final color = _getRiskColor(risk.severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getRiskIcon(risk.type), color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  risk.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  risk.severity.toString().split('.').last,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            risk.description,
            style: const TextStyle(fontSize: 12),
          ),
          if (risk.mitigation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Mitigation: ${risk.mitigation}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptimizationSuggestionsCard(List<String> tips) {
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
                  'Optimization Suggestions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(tip, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            )),
            if (tips.isEmpty)
              const Text(
                'No optimization suggestions available at this time.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningTab(YieldForecastState forecastState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPlantingScheduleCard(),
          const SizedBox(height: 16),
          _buildResourcePlanningCard(),
          const SizedBox(height: 16),
          _buildMarketingPlanCard(),
        ],
      ),
    );
  }

  Widget _buildPlantingScheduleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Optimal Planting Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FarmingCalendarWidget(
              selectedCrop: selectedCrop,
              onDateSelected: (date) => _planActivity(date),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcePlanningCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resource Requirements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildResourceItem('Seeds', '25 kg/ha', 'KES 12,500', Icons.eco),
            _buildResourceItem('Fertilizer', '200 kg/ha', 'KES 18,000', Icons.science),
            _buildResourceItem('Pesticides', '5 liters/ha', 'KES 8,500', Icons.spray_tan),
            _buildResourceItem('Labor', '45 man-days/ha', 'KES 22,500', Icons.person),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Cost per Hectare',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'KES 61,500',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(String resource, String quantity, String cost, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(quantity, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            cost,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketingPlanCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Marketing & Revenue Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Expected Yield'),
                      const Text('2,800 kg/ha', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Current Market Price'),
                      const Text('KES 45/kg', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gross Revenue'),
                      Text(
                        'KES 126,000',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Production Costs'),
                      const Text('KES 61,500', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net Profit',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'KES 64,500',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _createMarketingPlan(),
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Find Buyers'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(YieldForecastState forecastState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPerformanceMetricsCard(),
          const SizedBox(height: 16),
          _buildTrendAnalysisCard(),
          const SizedBox(height: 16),
          _buildBenchmarkingCard(),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('Accuracy', '87%', Icons.accuracy, Colors.green),
                ),
                Expanded(
                  child: _buildMetricItem('Efficiency', '92%', Icons.trending_up, Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('ROI', '105%', Icons.attach_money, Colors.orange),
                ),
                Expanded(
                  child: _buildMetricItem('Reliability', '94%', Icons.verified, Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
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
        ),
      ],
    );
  }

  Widget _buildTrendAnalysisCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yield Trends (5 Years)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const years = ['2020', '2021', '2022', '2023', '2024'];
                          if (value.toInt() >= 0 && value.toInt() < years.length) {
                            return Text(years[value.toInt()], style: const TextStyle(fontSize: 12));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 2200),
                        FlSpot(1, 2350),
                        FlSpot(2, 2500),
                        FlSpot(3, 2450),
                        FlSpot(4, 2800),
                      ],
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenchmarkingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Benchmarking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildBenchmarkItem(
              'vs. Regional Average',
              '+15%',
              'You are performing above the regional average',
              Colors.green,
            ),
            _buildBenchmarkItem(
              'vs. Top Performers',
              '-8%',
              'Room for improvement compared to top farmers',
              Colors.orange,
            ),
            _buildBenchmarkItem(
              'vs. Previous Year',
              '+12%',
              'Significant improvement from last season',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenchmarkItem(String comparison, String difference, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              difference,
              style: const TextStyle(
                color: Colors.white,
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
                  comparison,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(YieldForecastState forecastState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportGeneratorCard(),
          const SizedBox(height: 16),
          _buildRecentReportsCard(),
          const SizedBox(height: 16),
          _buildReportTemplatesCard(),
        ],
      ),
    );
  }

  Widget _buildReportGeneratorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateReport('season'),
                    icon: const Icon(Icons.summarize),
                    label: const Text('Season Summary'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateReport('financial'),
                    icon: const Icon(Icons.account_balance),
                    label: const Text('Financial Report'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _generateReport('yield'),
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Yield Analysis'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _generateReport('comparison'),
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Comparison'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReportsCard() {
    final recentReports = [
      {'title': 'Q4 2024 Yield Report', 'date': 'Dec 1, 2024', 'type': 'PDF'},
      {'title': 'Maize Season Summary', 'date': 'Nov 28, 2024', 'type': 'Excel'},
      {'title': 'Financial Analysis', 'date': 'Nov 25, 2024', 'type': 'PDF'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...recentReports.map((report) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                report['type'] == 'PDF' ? Icons.picture_as_pdf : Icons.table_chart,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(report['title']!),
              subtitle: Text(report['date']!),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _downloadReport(report['title']!),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTemplatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Templates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create custom report templates for your specific needs.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _createTemplate(),
                icon: const Icon(Icons.add_box),
                label: const Text('Create Template'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  List<ChartData> _getComparisonData() {
    return [
      ChartData('This Season', 2800),
      ChartData('Last Season', 2450),
      ChartData('Average', 2600),
      ChartData('Target', 3000),
    ];
  }

  List<ChartData> _getTrendData() {
    return [
      ChartData('2020', 2200),
      ChartData('2021', 2350),
      ChartData('2022', 2500),
      ChartData('2023', 2450),
      ChartData('2024', 2800),
    ];
  }

  Color _getRiskColor(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.low:
        return Colors.green;
      case RiskSeverity.medium:
        return Colors.orange;
      case RiskSeverity.high:
        return Colors.red;
    }
  }

  IconData _getRiskIcon(RiskType type) {
    switch (type) {
      case RiskType.weather:
        return Icons.wb_cloudy;
      case RiskType.pest:
        return Icons.bug_report;
      case RiskType.disease:
        return Icons.healing;
      case RiskType.market:
        return Icons.trending_down;
      case RiskType.financial:
        return Icons.attach_money;
    }
  }

  // Event handlers
  void _updateForecast() {
    ref.read(yieldForecastProvider.notifier).updateForecast(selectedCrop, selectedSeason);
  }

  void _addFarmingData() {
    // TODO: Navigate to farming data entry page
  }

  void _planActivity(DateTime date) {
    // TODO: Navigate to activity planning page
  }

  void _createMarketingPlan() {
    // TODO: Navigate to marketing plan page
  }

  void _generateReport(String reportType) {
    // TODO: Generate and download report
  }

  void _downloadReport(String reportTitle) {
    // TODO: Download existing report
  }

  void _createTemplate() {
    // TODO: Navigate to template creation page
  }
}

class ChartData {
  final String category;
  final double value;

  ChartData(this.category, this.value);
}