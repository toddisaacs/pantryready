import 'package:flutter/material.dart';
import 'package:pantryready/config/environment_config.dart';
import 'package:pantryready/services/data_service.dart';
import 'package:pantryready/services/data_service_factory.dart';
import 'package:pantryready/constants/app_constants.dart';

class EnvironmentSettingsScreen extends StatefulWidget {
  final Function(DataService) onDataServiceChanged;

  const EnvironmentSettingsScreen({
    super.key,
    required this.onDataServiceChanged,
  });

  @override
  State<EnvironmentSettingsScreen> createState() =>
      _EnvironmentSettingsScreenState();
}

class _EnvironmentSettingsScreenState extends State<EnvironmentSettingsScreen> {
  late Environment _currentEnvironment;
  late DataSource _currentDataSource;
  late String _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentEnvironment = EnvironmentConfig.environment;
    _currentDataSource = EnvironmentConfig.dataSource;
    _currentProfile = EnvironmentConfig.firestoreProfile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Settings'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildEnvironmentSection(),
          const SizedBox(height: 20),
          _buildDataSourceSection(),
          const SizedBox(height: 20),
          _buildFirestoreProfileSection(),
          const SizedBox(height: 20),
          _buildCurrentConfigSection(),
          const SizedBox(height: 20),
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildEnvironmentSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Environment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildEnvironmentOption(
              Environment.local,
              'Local Development',
              'Use mock data for development',
              Icons.computer,
            ),
            _buildEnvironmentOption(
              Environment.dev,
              'Development',
              'Use Firestore DEV profile',
              Icons.developer_mode,
            ),
            _buildEnvironmentOption(
              Environment.prod,
              'Production',
              'Use Firestore PROD profile',
              Icons.cloud,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentOption(
    Environment environment,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _currentEnvironment == environment;

    return ListTile(
      leading: Icon(
        icon,
        color:
            isSelected
                ? AppConstants.primaryColor
                : AppConstants.textSecondaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color:
              isSelected ? AppConstants.primaryColor : AppConstants.textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing:
          isSelected
              ? Icon(Icons.check_circle, color: AppConstants.primaryColor)
              : null,
      onTap: () => _selectEnvironment(environment),
    );
  }

  Widget _buildDataSourceSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildDataSourceOption(
              DataSource.mock,
              'Mock Data',
              'Use seeded sample data',
              Icons.data_usage,
            ),
            _buildDataSourceOption(
              DataSource.local,
              'Local Storage',
              'Use device storage',
              Icons.storage,
            ),
            _buildDataSourceOption(
              DataSource.firestore,
              'Firestore',
              'Use cloud database',
              Icons.cloud_queue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSourceOption(
    DataSource dataSource,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _currentDataSource == dataSource;

    return ListTile(
      leading: Icon(
        icon,
        color:
            isSelected
                ? AppConstants.primaryColor
                : AppConstants.textSecondaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color:
              isSelected ? AppConstants.primaryColor : AppConstants.textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing:
          isSelected
              ? Icon(Icons.check_circle, color: AppConstants.primaryColor)
              : null,
      onTap: () => _selectDataSource(dataSource),
    );
  }

  Widget _buildFirestoreProfileSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firestore Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Only applies when using Firestore data source',
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              'dev',
              'Development',
              'Use development database',
            ),
            _buildProfileOption(
              'prod',
              'Production',
              'Use production database',
            ),
            _buildProfileOption('test', 'Testing', 'Use testing database'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(String profile, String title, String subtitle) {
    final isSelected = _currentProfile == profile;

    return ListTile(
      leading: Icon(
        Icons.storage,
        color:
            isSelected
                ? AppConstants.primaryColor
                : AppConstants.textSecondaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color:
              isSelected ? AppConstants.primaryColor : AppConstants.textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing:
          isSelected
              ? Icon(Icons.check_circle, color: AppConstants.primaryColor)
              : null,
      onTap: () => _selectProfile(profile),
    );
  }

  Widget _buildCurrentConfigSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildConfigInfo(
              'Environment',
              EnvironmentConfig.getEnvironmentName(),
            ),
            _buildConfigInfo(
              'Data Source',
              EnvironmentConfig.getDataSourceName(),
            ),
            _buildConfigInfo(
              'Firestore Profile',
              _currentProfile.toUpperCase(),
            ),
            _buildConfigInfo('Full Config', EnvironmentConfig.getFullConfig()),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.refresh,
                color: AppConstants.primaryColor,
              ),
              title: const Text('Apply Configuration'),
              subtitle: const Text(
                'Switch to selected environment and data source',
              ),
              onTap: _applyConfiguration,
            ),
            ListTile(
              leading: const Icon(
                Icons.restore,
                color: AppConstants.accentColor,
              ),
              title: const Text('Reset to Default'),
              subtitle: const Text('Reset to local development with mock data'),
              onTap: _resetToDefault,
            ),
          ],
        ),
      ),
    );
  }

  void _selectEnvironment(Environment environment) {
    setState(() {
      _currentEnvironment = environment;
    });
  }

  void _selectDataSource(DataSource dataSource) {
    setState(() {
      _currentDataSource = dataSource;
    });
  }

  void _selectProfile(String profile) {
    setState(() {
      _currentProfile = profile;
    });
  }

  void _applyConfiguration() {
    // Configure environment
    switch (_currentEnvironment) {
      case Environment.local:
        EnvironmentConfig.configureForLocalDevelopment();
        break;
      case Environment.dev:
        EnvironmentConfig.configureForDev();
        break;
      case Environment.prod:
        EnvironmentConfig.configureForProd();
        break;
    }

    // Override data source if needed
    if (_currentDataSource != EnvironmentConfig.dataSource) {
      EnvironmentConfig.setDataSource(_currentDataSource);
    }

    // Override profile if needed
    if (_currentProfile != EnvironmentConfig.firestoreProfile) {
      EnvironmentConfig.setFirestoreProfile(_currentProfile);
    }

    // Get new data service
    final newDataService = DataServiceFactory.getDataService();

    // Notify parent
    widget.onDataServiceChanged(newDataService);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${EnvironmentConfig.getFullConfig()}'),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  void _resetToDefault() {
    final defaultService = DataServiceFactory.resetToDefault();
    widget.onDataServiceChanged(defaultService);

    setState(() {
      _currentEnvironment = EnvironmentConfig.environment;
      _currentDataSource = EnvironmentConfig.dataSource;
      _currentProfile = EnvironmentConfig.firestoreProfile;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to local development with mock data'),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }
}
