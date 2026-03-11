import 'package:flutter/material.dart';

class FarmRecordsPage extends StatefulWidget {
  const FarmRecordsPage({super.key});

  @override
  State<FarmRecordsPage> createState() => _FarmRecordsPageState();
}

class _FarmRecordsPageState extends State<FarmRecordsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFarm = 'Main Farm';
  String _selectedSeason = '2024 Season';

  final List<String> _farms = ['Main Farm', 'North Field', 'South Field', 'Coffee Plantation'];
  final List<String> _seasons = ['2024 Season', '2023 Season', '2022 Season'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text('Farm Records'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddRecordDialog,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportRecords,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Activities', icon: Icon(Icons.assignment)),
            Tab(text: 'Crops', icon: Icon(Icons.eco)),
            Tab(text: 'Inputs', icon: Icon(Icons.scatter_plot)),
            Tab(text: 'Harvest', icon: Icon(Icons.agriculture)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
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
                _buildActivitiesTab(),
                _buildCropsTab(),
                _buildInputsTab(),
                _buildHarvestTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRecordDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
        backgroundColor: Colors.brown,
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
              value: _selectedFarm,
              decoration: const InputDecoration(
                labelText: 'Farm',
                prefixIcon: Icon(Icons.landscape),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _farms.map((farm) => DropdownMenuItem(
                value: farm,
                child: Text(farm),
              )).toList(),
              onChanged: (value) => setState(() => _selectedFarm = value!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedSeason,
              decoration: const InputDecoration(
                labelText: 'Season',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _seasons.map((season) => DropdownMenuItem(
                value: season,
                child: Text(season),
              )).toList(),
              onChanged: (value) => setState(() => _selectedSeason = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    final activities = _getFarmActivities();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activity['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    activity['icon'],
                    color: activity['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        activity['description'],
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
                      activity['date'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (activity['cost'] != null)
                      Text(
                        'KES ${activity['cost']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (activity['notes'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activity['notes'],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editActivity(activity),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewActivityDetails(activity),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
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

  Widget _buildCropsTab() {
    final crops = _getCropRecords();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: crops.length,
      itemBuilder: (context, index) {
        final crop = crops[index];
        return _buildCropCard(crop);
      },
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${crop['variety']} • ${crop['area']} hectares',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStageColor(crop['stage']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              crop['stage'],
                              style: TextStyle(
                                fontSize: 10,
                                color: _getStageColor(crop['stage']),
                                fontWeight: FontWeight.bold,
                              ),
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
                      'Planted: ${crop['plantedDate']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (crop['expectedHarvest'] != null)
                      Text(
                        'Harvest: ${crop['expectedHarvest']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCropMetric('Investment', 'KES ${crop['investment']}', Icons.attach_money),
                ),
                Expanded(
                  child: _buildCropMetric('Expected Yield', '${crop['expectedYield']} tons', Icons.agriculture),
                ),
                Expanded(
                  child: _buildCropMetric('Health Score', '${crop['healthScore']}/10', Icons.favorite),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.brown, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputsTab() {
    final inputs = _getInputRecords();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputSummary(),
          const SizedBox(height: 20),
          const Text(
            'Input Records',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...inputs.map((input) => _buildInputCard(input)),
        ],
      ),
    );
  }

  Widget _buildInputSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input Summary - 2024 Season',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryMetric('Seeds', 'KES 25,000', Icons.eco, Colors.green),
                ),
                Expanded(
                  child: _buildSummaryMetric('Fertilizer', 'KES 45,000', Icons.scatter_plot, Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryMetric('Pesticides', 'KES 18,000', Icons.bug_report, Colors.red),
                ),
                Expanded(
                  child: _buildSummaryMetric('Labor', 'KES 35,000', Icons.people, Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
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

  Widget _buildInputCard(Map<String, dynamic> input) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: input['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                input['icon'],
                color: input['color'],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    input['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${input['quantity']} ${input['unit']} • ${input['date']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (input['supplier'] != null)
                    Text(
                      'Supplier: ${input['supplier']}',
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
                  'KES ${input['cost']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'KES ${input['unitCost']}/${input['unit']}',
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildHarvestTab() {
    final harvests = _getHarvestRecords();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHarvestSummary(),
          const SizedBox(height: 20),
          const Text(
            'Harvest Records',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...harvests.map((harvest) => _buildHarvestCard(harvest)),
        ],
      ),
    );
  }

  Widget _buildHarvestSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Harvest Summary - 2024 Season',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHarvestMetric('Total Yield', '45.2 tons', Icons.agriculture, Colors.green),
                ),
                Expanded(
                  child: _buildHarvestMetric('Revenue', 'KES 180,000', Icons.attach_money, Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHarvestMetric('Avg Quality', '8.5/10', Icons.star, Colors.orange),
                ),
                Expanded(
                  child: _buildHarvestMetric('Profit Margin', '35%', Icons.trending_up, Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHarvestMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestCard(Map<String, dynamic> harvest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: harvest['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    harvest['icon'],
                    color: harvest['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        harvest['crop'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Harvested: ${harvest['date']}',
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
                      '${harvest['quantity']} tons',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'KES ${harvest['revenue']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHarvestDetail('Quality', '${harvest['quality']}/10'),
                ),
                Expanded(
                  child: _buildHarvestDetail('Price/kg', 'KES ${harvest['pricePerKg']}'),
                ),
                Expanded(
                  child: _buildHarvestDetail('Buyer', harvest['buyer']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHarvestDetail(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceMetrics(),
          const SizedBox(height: 20),
          _buildProductivityAnalysis(),
          const SizedBox(height: 20),
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farm Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceCard('ROI', '35%', '+5%', Icons.trending_up, Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceCard('Yield/Ha', '3.2 tons', '+12%', Icons.agriculture, Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceCard('Cost/Ha', 'KES 45K', '-8%', Icons.attach_money, Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceCard('Efficiency', '87%', '+3%', Icons.speed, Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(String label, String value, String change, IconData icon, Color color) {
    final isPositive = change.startsWith('+');
    final changeColor = isPositive ? Colors.green : Colors.red;

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
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
              style: TextStyle(
                fontSize: 10,
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productivity Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAnalysisItem(
              'Best Performing Crop',
              'Coffee - 15% above average yield',
              Icons.coffee,
              Colors.brown,
            ),
            _buildAnalysisItem(
              'Most Profitable Season',
              'Dry Season 2024 - 42% profit margin',
              Icons.wb_sunny,
              Colors.orange,
            ),
            _buildAnalysisItem(
              'Cost Optimization',
              'Fertilizer costs reduced by 12% through bulk purchasing',
              Icons.trending_down,
              Colors.green,
            ),
            _buildAnalysisItem(
              'Quality Improvement',
              'Average crop quality increased from 7.2 to 8.5',
              Icons.star,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String description, IconData icon, Color color) {
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

  Widget _buildRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              'Increase Maize Planting',
              'Market analysis suggests 20% price increase next season',
              Icons.trending_up,
              Colors.green,
              'High Priority',
            ),
            _buildRecommendationItem(
              'Implement Drip Irrigation',
              'Could reduce water usage by 30% and increase yield by 15%',
              Icons.water_drop,
              Colors.blue,
              'Medium Priority',
            ),
            _buildRecommendationItem(
              'Diversify Crop Portfolio',
              'Add drought-resistant varieties to reduce climate risk',
              Icons.diversity_3,
              Colors.orange,
              'Low Priority',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description, IconData icon, Color color, String priority) {
    Color priorityColor;
    switch (priority) {
      case 'High Priority':
        priorityColor = Colors.red;
        break;
      case 'Medium Priority':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
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
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          fontSize: 10,
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'planted':
        return Colors.blue;
      case 'growing':
        return Colors.green;
      case 'flowering':
        return Colors.purple;
      case 'maturing':
        return Colors.orange;
      case 'ready':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getFarmActivities() {
    return [
      {
        'title': 'Maize Planting',
        'description': 'Planted hybrid maize variety in North Field',
        'date': 'Dec 15, 2024',
        'cost': '15,000',
        'icon': Icons.eco,
        'color': Colors.green,
        'notes': 'Used certified seeds from Kenya Seed Company. Applied basal fertilizer during planting.',
      },
      {
        'title': 'Fertilizer Application',
        'description': 'Applied NPK fertilizer to coffee plantation',
        'date': 'Dec 12, 2024',
        'cost': '8,500',
        'icon': Icons.scatter_plot,
        'color': Colors.blue,
        'notes': 'Applied 50kg NPK 17:17:17 per hectare as recommended by soil test.',
      },
      {
        'title': 'Pest Control',
        'description': 'Sprayed insecticide on bean crop',
        'date': 'Dec 10, 2024',
        'cost': '3,200',
        'icon': Icons.bug_report,
        'color': Colors.red,
        'notes': 'Controlled aphid infestation using organic neem-based pesticide.',
      },
      {
        'title': 'Irrigation',
        'description': 'Watered vegetable garden',
        'date': 'Dec 8, 2024',
        'cost': null,
        'icon': Icons.water_drop,
        'color': Colors.blue,
        'notes': 'Used drip irrigation system for 2 hours in the evening.',
      },
    ];
  }

  List<Map<String, dynamic>> _getCropRecords() {
    return [
      {
        'name': 'Maize',
        'variety': 'Hybrid H614',
        'area': '2.5',
        'stage': 'Growing',
        'plantedDate': 'Nov 15, 2024',
        'expectedHarvest': 'Mar 2025',
        'investment': '25,000',
        'expectedYield': '8.5',
        'healthScore': 9,
        'icon': Icons.grain,
        'color': Colors.amber,
      },
      {
        'name': 'Coffee',
        'variety': 'Arabica SL28',
        'area': '1.8',
        'stage': 'Flowering',
        'plantedDate': 'Permanent',
        'expectedHarvest': 'Jun 2025',
        'investment': '45,000',
        'expectedYield': '3.2',
        'healthScore': 8,
        'icon': Icons.coffee,
        'color': Colors.brown,
      },
      {
        'name': 'Beans',
        'variety': 'Climbing Beans',
        'area': '1.2',
        'stage': 'Maturing',
        'plantedDate': 'Oct 20, 2024',
        'expectedHarvest': 'Jan 2025',
        'investment': '18,000',
        'expectedYield': '2.8',
        'healthScore': 7,
        'icon': Icons.eco,
        'color': Colors.green,
      },
    ];
  }

  List<Map<String, dynamic>> _getInputRecords() {
    return [
      {
        'name': 'NPK Fertilizer 17:17:17',
        'quantity': '200',
        'unit': 'kg',
        'cost': '12,000',
        'unitCost': '60',
        'date': 'Dec 1, 2024',
        'supplier': 'Yara Kenya',
        'icon': Icons.scatter_plot,
        'color': Colors.blue,
      },
      {
        'name': 'Hybrid Maize Seeds',
        'quantity': '25',
        'unit': 'kg',
        'cost': '8,500',
        'unitCost': '340',
        'date': 'Nov 10, 2024',
        'supplier': 'Kenya Seed Company',
        'icon': Icons.eco,
        'color': Colors.green,
      },
      {
        'name': 'Organic Pesticide',
        'quantity': '5',
        'unit': 'liters',
        'cost': '3,200',
        'unitCost': '640',
        'date': 'Dec 5, 2024',
        'supplier': 'Osho Chemicals',
        'icon': Icons.bug_report,
        'color': Colors.red,
      },
    ];
  }

  List<Map<String, dynamic>> _getHarvestRecords() {
    return [
      {
        'crop': 'Beans',
        'quantity': '2.8',
        'revenue': '42,000',
        'quality': '8.5',
        'pricePerKg': '150',
        'buyer': 'Local Market',
        'date': 'Dec 20, 2024',
        'icon': Icons.eco,
        'color': Colors.green,
      },
      {
        'crop': 'Coffee',
        'quantity': '1.2',
        'revenue': '84,000',
        'quality': '9.2',
        'pricePerKg': '280',
        'buyer': 'Export Company',
        'date': 'Nov 25, 2024',
        'icon': Icons.coffee,
        'color': Colors.brown,
      },
      {
        'crop': 'Vegetables',
        'quantity': '0.8',
        'revenue': '12,000',
        'quality': '7.8',
        'pricePerKg': '75',
        'buyer': 'Supermarket',
        'date': 'Dec 10, 2024',
        'icon': Icons.local_grocery_store,
        'color': Colors.orange,
      },
    ];
  }

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Farm Record'),
        content: const Text('Record entry form would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _exportRecords() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting farm records...'),
        backgroundColor: Colors.brown,
      ),
    );
  }

  void _editActivity(Map<String, dynamic> activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${activity['title']}...'),
        backgroundColor: Colors.brown,
      ),
    );
  }

  void _viewActivityDetails(Map<String, dynamic> activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for ${activity['title']}...'),
        backgroundColor: Colors.brown,
      ),
    );
  }
}