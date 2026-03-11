import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  
  final List<String> _periods = ['This Week', 'This Month', 'This Quarter', 'This Year'];

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
        title: const Text('Financial Management'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTransactionDialog,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportReport,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Loans', icon: Icon(Icons.account_balance)),
            Tab(text: 'Insurance', icon: Icon(Icons.security)),
            Tab(text: 'Reports', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildLoansTab(),
                _buildInsuranceTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildPeriodSelector() {
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
          const Icon(Icons.calendar_today, color: Colors.purple),
          const SizedBox(width: 12),
          const Text('Period: ', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedPeriod,
            underline: const SizedBox(),
            items: _periods.map((period) => DropdownMenuItem(
              value: period,
              child: Text(period),
            )).toList(),
            onChanged: (value) => setState(() => _selectedPeriod = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialSummary(),
          const SizedBox(height: 20),
          _buildIncomeExpenseChart(),
          const SizedBox(height: 20),
          _buildRecentTransactions(),
          const SizedBox(height: 20),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Income',
            'KES 125,000',
            '+15%',
            Icons.trending_up,
            Colors.green,
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Expenses',
            'KES 85,000',
            '+8%',
            Icons.trending_down,
            Colors.red,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, String change, IconData icon, Color color, bool isPositive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Income vs Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 50000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${(value / 1000).toInt()}K',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _generateBarData(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = _getRecentTransactions();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _showAllTransactions,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...transactions.take(5).map((transaction) => _buildTransactionItem(transaction)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isIncome = transaction['type'] == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.add : Icons.remove;

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
                  transaction['description'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  transaction['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}KES ${transaction['amount']}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Apply for Loan',
                    Icons.account_balance,
                    Colors.blue,
                    () => _tabController.animateTo(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Get Insurance',
                    Icons.security,
                    Colors.green,
                    () => _tabController.animateTo(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Budget Planner',
                    Icons.pie_chart,
                    Colors.orange,
                    _showBudgetPlanner,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Tax Calculator',
                    Icons.calculate,
                    Colors.purple,
                    _showTaxCalculator,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(title, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildLoansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLoanSummary(),
          const SizedBox(height: 20),
          _buildAvailableLoans(),
          const SizedBox(height: 20),
          _buildLoanHistory(),
        ],
      ),
    );
  }

  Widget _buildLoanSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLoanMetric('Active Loans', '2', Icons.account_balance, Colors.blue),
                ),
                Expanded(
                  child: _buildLoanMetric('Total Debt', 'KES 45,000', Icons.money_off, Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLoanMetric('Credit Score', '750', Icons.star, Colors.green),
                ),
                Expanded(
                  child: _buildLoanMetric('Next Payment', 'KES 5,000', Icons.schedule, Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanMetric(String label, String value, IconData icon, Color color) {
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

  Widget _buildAvailableLoans() {
    final loans = _getAvailableLoans();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Loan Products',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...loans.map((loan) => _buildLoanCard(loan)),
      ],
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> loan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(loan['icon'], color: loan['color'], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loan['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: loan['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${loan['rate']}% APR',
                    style: TextStyle(
                      color: loan['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              loan['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ${loan['amount']}'),
                      Text('Term: ${loan['term']}'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _applyForLoan(loan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: loan['color'],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildLoanHistoryItem('Farm Equipment Loan', 'KES 25,000', 'Active', Colors.green),
            _buildLoanHistoryItem('Seed Capital Loan', 'KES 20,000', 'Active', Colors.green),
            _buildLoanHistoryItem('Fertilizer Loan', 'KES 15,000', 'Completed', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanHistoryItem(String name, String amount, String status, Color color) {
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
            child: Icon(Icons.account_balance, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  amount,
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsuranceSummary(),
          const SizedBox(height: 20),
          _buildInsuranceProducts(),
          const SizedBox(height: 20),
          _buildClaimsHistory(),
        ],
      ),
    );
  }

  Widget _buildInsuranceSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insurance Coverage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsuranceMetric('Active Policies', '3', Icons.security, Colors.green),
                ),
                Expanded(
                  child: _buildInsuranceMetric('Coverage Value', 'KES 200K', Icons.shield, Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInsuranceMetric('Premium Paid', 'KES 12K', Icons.payment, Colors.orange),
                ),
                Expanded(
                  child: _buildInsuranceMetric('Claims Made', '1', Icons.assignment, Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceMetric(String label, String value, IconData icon, Color color) {
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

  Widget _buildInsuranceProducts() {
    final products = _getInsuranceProducts();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Insurance Products',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...products.map((product) => _buildInsuranceProductCard(product)),
      ],
    );
  }

  Widget _buildInsuranceProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(product['icon'], color: product['color'], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product['premium'],
                    style: TextStyle(
                      color: product['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coverage: ${product['coverage']}'),
                      Text('Deductible: ${product['deductible']}'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _getInsuranceQuote(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: product['color'],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Get Quote'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimsHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Claims History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _fileClaim,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('File Claim'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildClaimItem('Drought Damage - Maize', 'KES 15,000', 'Approved', Colors.green),
            _buildClaimItem('Pest Damage - Coffee', 'KES 8,000', 'Processing', Colors.orange),
            _buildClaimItem('Equipment Damage', 'KES 25,000', 'Rejected', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimItem(String description, String amount, String status, Color color) {
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
            child: Icon(Icons.assignment, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  amount,
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportOptions(),
          const SizedBox(height: 20),
          _buildProfitLossChart(),
          const SizedBox(height: 20),
          _buildExpenseBreakdown(),
        ],
      ),
    );
  }

  Widget _buildReportOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildReportButton(
                    'Profit & Loss',
                    Icons.trending_up,
                    Colors.green,
                    _generateProfitLossReport,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReportButton(
                    'Cash Flow',
                    Icons.account_balance_wallet,
                    Colors.blue,
                    _generateCashFlowReport,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildReportButton(
                    'Tax Summary',
                    Icons.receipt,
                    Colors.orange,
                    _generateTaxReport,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReportButton(
                    'Budget vs Actual',
                    Icons.compare_arrows,
                    Colors.purple,
                    _generateBudgetReport,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(title, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildProfitLossChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profit & Loss Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${(value / 1000).toInt()}K',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          return Text(
                            months[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateProfitData(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
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

  Widget _buildExpenseBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _generateExpenseData(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Seeds', Colors.green, '35%'),
                      _buildLegendItem('Fertilizer', Colors.blue, '25%'),
                      _buildLegendItem('Labor', Colors.orange, '20%'),
                      _buildLegendItem('Equipment', Colors.red, '15%'),
                      _buildLegendItem('Other', Colors.purple, '5%'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(percentage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarData() {
    return [
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(toY: 30000, color: Colors.green, width: 16),
        BarChartRodData(toY: 20000, color: Colors.red, width: 16),
      ]),
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(toY: 35000, color: Colors.green, width: 16),
        BarChartRodData(toY: 25000, color: Colors.red, width: 16),
      ]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(toY: 40000, color: Colors.green, width: 16),
        BarChartRodData(toY: 30000, color: Colors.red, width: 16),
      ]),
      BarChartGroupData(x: 3, barRods: [
        BarChartRodData(toY: 45000, color: Colors.green, width: 16),
        BarChartRodData(toY: 35000, color: Colors.red, width: 16),
      ]),
      BarChartGroupData(x: 4, barRods: [
        BarChartRodData(toY: 38000, color: Colors.green, width: 16),
        BarChartRodData(toY: 28000, color: Colors.red, width: 16),
      ]),
      BarChartGroupData(x: 5, barRods: [
        BarChartRodData(toY: 42000, color: Colors.green, width: 16),
        BarChartRodData(toY: 32000, color: Colors.red, width: 16),
      ]),
    ];
  }

  List<FlSpot> _generateProfitData() {
    return [
      const FlSpot(0, 10000),
      const FlSpot(1, 15000),
      const FlSpot(2, 12000),
      const FlSpot(3, 18000),
      const FlSpot(4, 22000),
      const FlSpot(5, 25000),
    ];
  }

  List<PieChartSectionData> _generateExpenseData() {
    return [
      PieChartSectionData(value: 35, color: Colors.green, title: '35%', radius: 60),
      PieChartSectionData(value: 25, color: Colors.blue, title: '25%', radius: 60),
      PieChartSectionData(value: 20, color: Colors.orange, title: '20%', radius: 60),
      PieChartSectionData(value: 15, color: Colors.red, title: '15%', radius: 60),
      PieChartSectionData(value: 5, color: Colors.purple, title: '5%', radius: 60),
    ];
  }

  List<Map<String, dynamic>> _getRecentTransactions() {
    return [
      {'description': 'Maize Sale', 'amount': '25,000', 'date': 'Dec 15, 2024', 'type': 'income'},
      {'description': 'Fertilizer Purchase', 'amount': '8,500', 'date': 'Dec 14, 2024', 'type': 'expense'},
      {'description': 'Coffee Sale', 'amount': '45,000', 'date': 'Dec 12, 2024', 'type': 'income'},
      {'description': 'Labor Costs', 'amount': '12,000', 'date': 'Dec 10, 2024', 'type': 'expense'},
      {'description': 'Equipment Rental', 'amount': '5,000', 'date': 'Dec 8, 2024', 'type': 'expense'},
    ];
  }

  List<Map<String, dynamic>> _getAvailableLoans() {
    return [
      {
        'name': 'Farm Equipment Loan',
        'description': 'Low-interest loans for purchasing farm equipment and machinery',
        'rate': 8.5,
        'amount': 'Up to KES 500,000',
        'term': '1-5 years',
        'icon': Icons.agriculture,
        'color': Colors.green,
      },
      {
        'name': 'Seasonal Crop Loan',
        'description': 'Short-term financing for seeds, fertilizers, and seasonal expenses',
        'rate': 12.0,
        'amount': 'Up to KES 200,000',
        'term': '6-12 months',
        'icon': Icons.eco,
        'color': Colors.blue,
      },
      {
        'name': 'Livestock Loan',
        'description': 'Financing for purchasing livestock and related infrastructure',
        'rate': 10.5,
        'amount': 'Up to KES 300,000',
        'term': '2-4 years',
        'icon': Icons.pets,
        'color': Colors.orange,
      },
    ];
  }

  List<Map<String, dynamic>> _getInsuranceProducts() {
    return [
      {
        'name': 'Crop Insurance',
        'description': 'Protection against crop loss due to weather, pests, and diseases',
        'premium': 'KES 5,000/year',
        'coverage': 'Up to KES 100,000',
        'deductible': 'KES 2,000',
        'icon': Icons.eco,
        'color': Colors.green,
      },
      {
        'name': 'Livestock Insurance',
        'description': 'Coverage for livestock against death, theft, and disease',
        'premium': 'KES 8,000/year',
        'coverage': 'Up to KES 150,000',
        'deductible': 'KES 3,000',
        'icon': Icons.pets,
        'color': Colors.blue,
      },
      {
        'name': 'Equipment Insurance',
        'description': 'Protection for farm equipment and machinery',
        'premium': 'KES 12,000/year',
        'coverage': 'Up to KES 200,000',
        'deductible': 'KES 5,000',
        'icon': Icons.build,
        'color': Colors.orange,
      },
    ];
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Transaction'),
        content: const Text('Transaction entry form would be displayed here.'),
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

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting financial report...'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _showAllTransactions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening full transaction history...'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _showBudgetPlanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening budget planner...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showTaxCalculator() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening tax calculator...'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _applyForLoan(Map<String, dynamic> loan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applying for ${loan['name']}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _getInsuranceQuote(Map<String, dynamic> product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Getting quote for ${product['name']}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _fileClaim() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening claim filing form...'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _generateProfitLossReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating Profit & Loss report...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _generateCashFlowReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating Cash Flow report...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _generateTaxReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating Tax Summary report...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _generateBudgetReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating Budget vs Actual report...'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}