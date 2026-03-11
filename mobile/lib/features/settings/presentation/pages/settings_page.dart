import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.settings, 
              size: isSmallScreen ? 48 : 64, 
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Settings',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Customize your app experience',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 32),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionHeader('General'),
                  _buildSwitchTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Receive push notifications',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme',
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    icon: Icons.location_on,
                    title: 'Location Services',
                    subtitle: 'Allow location access',
                    value: _locationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _locationEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Preferences'),
                  _buildLanguageTile(),
                  _buildSettingsTile(
                    icon: Icons.storage,
                    title: 'Data & Storage',
                    subtitle: 'Manage app data and cache',
                  ),
                  _buildSettingsTile(
                    icon: Icons.sync,
                    title: 'Sync Settings',
                    subtitle: 'Configure data synchronization',
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Support'),
                  _buildSettingsTile(
                    icon: Icons.help,
                    title: 'Help & FAQ',
                    subtitle: 'Get help and support',
                  ),
                  _buildSettingsTile(
                    icon: Icons.feedback,
                    title: 'Send Feedback',
                    subtitle: 'Share your thoughts with us',
                  ),
                  _buildSettingsTile(
                    icon: Icons.info,
                    title: 'About',
                    subtitle: 'App version and legal information',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: isSmallScreen ? 6 : 8, 
        top: isSmallScreen ? 6 : 8,
      ),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 4 : 8,
        ),
      ),
    );
  }

  Widget _buildLanguageTile() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
      child: ListTile(
        leading: Icon(Icons.language, color: theme.colorScheme.primary),
        title: Text(
          'Language',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _selectedLanguage,
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 4 : 8,
        ),
        onTap: () {
          _showLanguageDialog();
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 4 : 8,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title feature coming soon!'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showLanguageDialog() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Language',
            style: theme.textTheme.titleLarge,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: isSmallScreen ? 12 : 20,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption('English'),
                _buildLanguageOption('Swahili'),
                _buildLanguageOption('Amharic'),
                _buildLanguageOption('French'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _selectedLanguage,
      onChanged: (String? value) {
        setState(() {
          _selectedLanguage = value!;
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $value (feature coming soon!)'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}