import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/loan_application.dart';
import '../../data/models/insurance_policy.dart';
import '../providers/microfinance_provider.dart';
import '../widgets/loan_application_card.dart';
import '../widgets/insurance_card.dart';
import '../widgets/credit_score_widget.dart';

class MicrofinancePage extends ConsumerStatefulWidget {
  const MicrofinancePage({super.key});

  @override
  ConsumerState<MicrofinancePage> createState() => _MicrofinancePageState();
}

class _MicrofinancePageState extends ConsumerState<MicrofinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final financeState = ref.watch(microfinanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Services'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Loans', icon: Icon(Icons.attach_money)),
            Tab(text: 'Insurance', icon: Icon(Icons.security)),
            Tab(text: 'Savings', icon: Icon(Icons.savings)),
            Tab(text: 'Credit Score', icon: Icon(Icons.assessment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoansTab(financeState),
          _buildInsuranceTab(financeState),
          _buildSavingsTab(financeState),
          _buildCreditScoreTab(financeState),
        ],
      ),
    );
  }

  Widget _buildLoansTab(MicrofinanceState financeState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLoanOverviewCard(financeState),
          const SizedBox(height: 16),
          _buildAvailableLoansSection(),
          const SizedBox(height: 16),
          _buildMyLoansSection(financeState.loanApplications),
        ],
      ),
    );
  }

  Widget _buildLoanOverviewCard(MicrofinanceState financeState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Loan Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    'Available Credit',
                    'KES ${financeState.availableCredit.toStringAsFixed(0)}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    'Outstanding',
                    'KES ${financeState.outstandingBalance.toStringAsFixed(0)}',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    'Next Payment',
                    financeState.nextPaymentDate != null
                        ? _formatDate(financeState.nextPaymentDate!)
                        : 'No loans',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    'Credit Score',
                    '${financeState.creditScore}/850',
                    _getCreditScoreColor(financeState.creditScore),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableLoansSection() {
    final availableLoans = [
      {
        'title': 'Agricultural Input Loan',
        'description': 'Finance seeds, fertilizers, and equipment',
        'rate': '8% p.a.',
        'amount': 'Up to KES 500,000',
        'term': '6-12 months',
        'eligibility': 'Farming data required',
      },
      {
        'title': 'Equipment Purchase Loan',
        'description': 'Buy farming equipment and machinery',
        'rate': '10% p.a.',
        'amount': 'Up to KES 2,000,000',
        'term': '12-36 months',
        'eligibility': 'Collateral required',
      },
      {
        'title': 'Emergency Crop Loan',
        'description': 'Quick loans for urgent farming needs',
        'rate': '12% p.a.',
        'amount': 'Up to KES 100,000',
        'term': '3-6 months',
        'eligibility': 'Good credit score',
      },
      {
        'title': 'Harvest Season Loan',
        'description': 'Bridge finance until harvest season',
        'rate': '9% p.a.',
        'amount': 'Up to KES 300,000',
        'term': '3-9 months',
        'eligibility': 'Crop insurance required',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Loan Products',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...availableLoans.map((loan) => _buildLoanProductCard(loan)),
      ],
    );
  }

  Widget _buildLoanProductCard(Map<String, String> loan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loan['description']!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    loan['rate']!,
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLoanDetail(Icons.attach_money, loan['amount']!),
                _buildLoanDetail(Icons.schedule, loan['term']!),
                _buildLoanDetail(Icons.check_circle, loan['eligibility']!),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _applyForLoan(loan['title']!),
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetail(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyLoansSection(List<LoanApplication> loans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Loan Applications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (loans.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No loan applications yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Apply for a loan to see your applications here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...loans.map((loan) => LoanApplicationCard(
                application: loan,
                onTap: () => _viewLoanDetails(loan),
              )),
      ],
    );
  }

  Widget _buildInsuranceTab(MicrofinanceState financeState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsuranceOverviewCard(),
          const SizedBox(height: 16),
          _buildAvailableInsuranceSection(),
          const SizedBox(height: 16),
          _buildMyInsuranceSection(financeState.insurancePolicies),
        ],
      ),
    );
  }

  Widget _buildInsuranceOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Crop Insurance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Protect your crops against weather risks, pests, and diseases. Get compensation for crop losses.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Insurance premiums can be as low as 5% of your expected harvest value',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
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

  Widget _buildAvailableInsuranceSection() {
    final insuranceProducts = [
      {
        'title': 'Weather Index Insurance',
        'description': 'Protection against drought and excessive rainfall',
        'coverage': 'Up to 80% of crop value',
        'premium': '5-8% of sum insured',
        'crops': 'Maize, Beans, Coffee, Tea',
      },
      {
        'title': 'Comprehensive Crop Insurance',
        'description': 'Full coverage against all perils including pests',
        'coverage': 'Up to 100% of crop value',
        'premium': '8-12% of sum insured',
        'crops': 'All major crops',
      },
      {
        'title': 'Livestock Insurance',
        'description': 'Protection for cattle, goats, and poultry',
        'coverage': 'Up to market value',
        'premium': '6-10% of animal value',
        'crops': 'Cattle, Goats, Poultry',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Insurance Products',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...insuranceProducts.map((insurance) => _buildInsuranceProductCard(insurance)),
      ],
    );
  }

  Widget _buildInsuranceProductCard(Map<String, String> insurance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              insurance['title']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              insurance['description']!,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInsuranceDetail('Coverage', insurance['coverage']!),
                _buildInsuranceDetail('Premium', insurance['premium']!),
              ],
            ),
            const SizedBox(height: 8),
            _buildInsuranceDetail('Eligible Crops', insurance['crops']!),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _getInsuranceQuote(insurance['title']!),
                child: const Text('Get Quote'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMyInsuranceSection(List<InsurancePolicy> policies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Insurance Policies',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (policies.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.security_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No insurance policies yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Protect your crops with insurance',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...policies.map((policy) => InsuranceCard(
                policy: policy,
                onTap: () => _viewPolicyDetails(policy),
              )),
      ],
    );
  }

  Widget _buildSavingsTab(MicrofinanceState financeState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSavingsOverviewCard(financeState),
          const SizedBox(height: 16),
          _buildSavingsGoalsCard(),
          const SizedBox(height: 16),
          _buildSavingsProductsCard(),
        ],
      ),
    );
  }

  Widget _buildSavingsOverviewCard(MicrofinanceState financeState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'My Savings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'KES ${financeState.savingsBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Interest Earned This Month: KES ${(financeState.savingsBalance * 0.005).toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _depositMoney(),
                    child: const Text('Deposit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _withdrawMoney(),
                    child: const Text('Withdraw'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsGoalsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Savings Goals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSavingsGoalItem('Equipment Fund', 50000, 32000),
            _buildSavingsGoalItem('Emergency Fund', 25000, 18500),
            _buildSavingsGoalItem('Next Season Seeds', 15000, 12000),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _createSavingsGoal(),
                child: const Text('Create New Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsGoalItem(String title, double target, double current) {
    final progress = current / target;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                'KES ${current.toStringAsFixed(0)} / KES ${target.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% complete',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsProductsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Savings Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSavingsProductItem(
              'Fixed Deposit',
              '6% p.a.',
              'Lock your money for higher returns',
              Icons.lock,
            ),
            _buildSavingsProductItem(
              'Rotating Savings (Chama)',
              'Variable',
              'Join a community savings group',
              Icons.group,
            ),
            _buildSavingsProductItem(
              'Mobile Money Integration',
              'Instant',
              'Save directly from your mobile money',
              Icons.phone_android,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsProductItem(
    String title,
    String rate,
    String description,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      rate,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditScoreTab(MicrofinanceState financeState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CreditScoreWidget(
            score: financeState.creditScore,
            factors: financeState.creditFactors,
          ),
          const SizedBox(height: 16),
          _buildCreditHistoryCard(),
          const SizedBox(height: 16),
          _buildCreditImprovementTips(),
        ],
      ),
    );
  }

  Widget _buildCreditHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credit History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCreditHistoryItem('Payment History', '95%', Colors.green),
            _buildCreditHistoryItem('Farming Data Quality', '88%', Colors.green),
            _buildCreditHistoryItem('Income Stability', '72%', Colors.orange),
            _buildCreditHistoryItem('Debt to Income Ratio', '65%', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditHistoryItem(String factor, String score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(factor),
          Text(
            score,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditImprovementTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Improve Your Credit Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCreditTip(
              'Keep detailed farming records',
              'Regular data entry about your crops, yields, and expenses improves your score',
              Icons.assignment,
            ),
            _buildCreditTip(
              'Make timely loan payments',
              'Pay your loans on time to build a positive payment history',
              Icons.schedule,
            ),
            _buildCreditTip(
              'Diversify your crops',
              'Growing multiple crop types reduces risk and improves creditworthiness',
              Icons.agriculture,
            ),
            _buildCreditTip(
              'Use insurance products',
              'Having crop insurance shows responsible risk management',
              Icons.security,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditTip(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
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

  Color _getCreditScoreColor(int score) {
    if (score >= 750) return Colors.green;
    if (score >= 650) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _applyForLoan(String loanType) {
    // TODO: Navigate to loan application form
  }

  void _viewLoanDetails(LoanApplication loan) {
    // TODO: Navigate to loan details page
  }

  void _getInsuranceQuote(String insuranceType) {
    // TODO: Navigate to insurance quote form
  }

  void _viewPolicyDetails(InsurancePolicy policy) {
    // TODO: Navigate to policy details page
  }

  void _depositMoney() {
    // TODO: Show deposit dialog
  }

  void _withdrawMoney() {
    // TODO: Show withdrawal dialog
  }

  void _createSavingsGoal() {
    // TODO: Show create savings goal dialog
  }
}