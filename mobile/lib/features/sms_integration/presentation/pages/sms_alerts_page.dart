import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sms_alert.dart';
import '../providers/sms_provider.dart';
import '../widgets/sms_alert_card.dart';
import '../widgets/sms_settings_dialog.dart';

class SmsAlertsPage extends ConsumerStatefulWidget {
  const SmsAlertsPage({super.key});

  @override
  ConsumerState<SmsAlertsPage> createState() => _SmsAlertsPageState();
}

class _SmsAlertsPageState extends ConsumerState<SmsAlertsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final smsState = ref.watch(smsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Alerts & USSD'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Alerts', icon: Icon(Icons.notifications)),
            Tab(text: 'USSD', icon: Icon(Icons.phone)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert),
            onPressed: () => _showCreateAlertDialog(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertsTab(smsState),
          _buildUssdTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(SmsState smsState) {
    return Column(
      children: [
        _buildAlertTypesSelector(),
        Expanded(
          child: smsState.alerts.isEmpty
              ? _buildEmptyAlertsView()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: smsState.alerts.length,
                  itemBuilder: (context, index) {
                    final alert = smsState.alerts[index];
                    return SmsAlertCard(
                      alert: alert,
                      onToggle: (enabled) => _toggleAlert(alert, enabled),
                      onEdit: () => _editAlert(alert),
                      onDelete: () => _deleteAlert(alert),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAlertTypesSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Critical Alerts (SMS Backup)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'These alerts will be sent via SMS when internet is unavailable:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildAlertChip(Icons.wb_sunny, 'Weather Warnings', true),
              _buildAlertChip(Icons.trending_up, 'Price Alerts', true),
              _buildAlertChip(Icons.local_hospital, 'Disease Outbreaks', true),
              _buildAlertChip(Icons.attach_money, 'Payment Reminders', false),
              _buildAlertChip(Icons.calendar_today, 'Planting Reminders', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertChip(IconData icon, String label, bool enabled) {
    return FilterChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: enabled,
      onSelected: (selected) {
        // Toggle alert type
        ref.read(smsProvider.notifier).toggleAlertType(label, selected);
      },
    );
  }

  Widget _buildEmptyAlertsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No SMS alerts configured',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up SMS alerts to stay informed\neven when offline',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateAlertDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }

  Widget _buildUssdTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUssdInfoCard(),
          const SizedBox(height: 16),
          _buildUssdCommandsCard(),
          const SizedBox(height: 16),
          _buildQuickUssdActions(),
        ],
      ),
    );
  }

  Widget _buildUssdInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'USSD Quick Access',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Access agricultural information via USSD codes when you don\'t have internet connectivity. Works on any mobile phone.',
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
                  Text(
                    'Main USSD Code: *384*AGRI#',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dial this code to access the agricultural menu',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
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

  Widget _buildUssdCommandsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available USSD Commands',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildUssdCommand('*384*1#', 'Weather forecast for your area'),
            _buildUssdCommand('*384*2#', 'Current crop prices'),
            _buildUssdCommand('*384*3#', 'Disease alerts and tips'),
            _buildUssdCommand('*384*4#', 'Farming calendar and advice'),
            _buildUssdCommand('*384*5#', 'Market information'),
            _buildUssdCommand('*384*6#', 'Financial services'),
            _buildUssdCommand('*384*9#', 'Emergency agricultural hotline'),
          ],
        ),
      ),
    );
  }

  Widget _buildUssdCommand(String code, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(description),
          ),
          IconButton(
            icon: const Icon(Icons.phone, size: 20),
            onPressed: () => _dialUssdCode(code),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickUssdActions() {
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildQuickActionButton(
                  'Weather',
                  Icons.wb_sunny,
                  Colors.orange,
                  () => _dialUssdCode('*384*1#'),
                ),
                _buildQuickActionButton(
                  'Prices',
                  Icons.trending_up,
                  Colors.green,
                  () => _dialUssdCode('*384*2#'),
                ),
                _buildQuickActionButton(
                  'Disease Alert',
                  Icons.warning,
                  Colors.red,
                  () => _dialUssdCode('*384*3#'),
                ),
                _buildQuickActionButton(
                  'Emergency',
                  Icons.emergency,
                  Colors.red.shade800,
                  () => _dialUssdCode('*384*9#'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPhoneNumberSettings(),
          const SizedBox(height: 16),
          _buildLanguageSettings(),
          const SizedBox(height: 16),
          _buildNotificationSettings(),
          const SizedBox(height: 16),
          _buildDataUsageSettings(),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phone Number Registration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Register your phone number to receive SMS alerts and access USSD services.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+254 ',
                hintText: '7XX XXX XXX',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _verifyPhoneNumber(),
                child: const Text('Verify Phone Number'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SMS Language Preference',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Choose your preferred language for SMS alerts:'),
            const SizedBox(height: 16),
            ...['English', 'Swahili', 'Amharic', 'French'].map((language) =>
                RadioListTile<String>(
                  title: Text(language),
                  value: language,
                  groupValue: 'English', // TODO: Get from provider
                  onChanged: (value) => _changeLanguage(value!),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alert Frequency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Weather Alerts'),
              subtitle: const Text('Daily weather updates'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Price Alerts'),
              subtitle: const Text('When prices change by 10% or more'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Disease Alerts'),
              subtitle: const Text('Urgent disease outbreak notifications'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataUsageSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Optimize data usage for low-bandwidth connections:',
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Offline Mode'),
              subtitle: const Text('Use cached data when connectivity is poor'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Compress Images'),
              subtitle: const Text('Reduce image quality to save data'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => const SmsSettingsDialog(),
    );
  }

  void _toggleAlert(SmsAlert alert, bool enabled) {
    ref.read(smsProvider.notifier).toggleAlert(alert.id, enabled);
  }

  void _editAlert(SmsAlert alert) {
    showDialog(
      context: context,
      builder: (context) => SmsSettingsDialog(alert: alert),
    );
  }

  void _deleteAlert(SmsAlert alert) {
    ref.read(smsProvider.notifier).deleteAlert(alert.id);
  }

  void _dialUssdCode(String code) {
    ref.read(smsProvider.notifier).dialUssdCode(code);
  }

  void _verifyPhoneNumber() {
    // TODO: Implement phone number verification
  }

  void _changeLanguage(String language) {
    // TODO: Implement language change
  }
}