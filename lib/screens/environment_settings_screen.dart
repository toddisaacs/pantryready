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

  @override
  void initState() {
    super.initState();
    _currentEnvironment = EnvironmentConfig.environment;
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
            const SizedBox(height: 8),
            const Text(
              'Choose your environment. This will automatically configure the data source and Firestore profile.',
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildEnvironmentOption(
              Environment.local,
              'Local Development',
              'Use mock data for development (in-memory, resets on restart)',
              Icons.computer,
            ),
            _buildEnvironmentOption(
              Environment.dev,
              'Development',
              'Use Firestore DEV profile for testing',
              Icons.developer_mode,
            ),
            _buildEnvironmentOption(
              Environment.prod,
              'Production',
              'Use Firestore PROD profile for live data',
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
    String description,
    IconData icon,
  ) {
    final isSelected = _currentEnvironment == environment;
    return Card(
      elevation: isSelected ? 4 : 1,
      color:
          isSelected ? AppConstants.primaryColor.withValues(alpha: 0.1) : null,
      child: ListTile(
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
        subtitle: Text(
          description,
          style: TextStyle(
            color:
                isSelected
                    ? AppConstants.primaryColor
                    : AppConstants.textSecondaryColor,
          ),
        ),
        trailing:
            isSelected
                ? Icon(Icons.check_circle, color: AppConstants.primaryColor)
                : null,
        onTap: () => _selectEnvironment(environment),
      ),
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
            _buildConfigRow('Environment', EnvironmentConfig.environment.name),
            _buildConfigRow('Data Source', EnvironmentConfig.dataSource.name),
            if (EnvironmentConfig.useFirestore)
              _buildConfigRow(
                'Firestore Profile',
                EnvironmentConfig.firestoreProfile,
              ),
            _buildConfigRow(
              'Production Mode',
              EnvironmentConfig.isProduction.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppConstants.textColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppConstants.textSecondaryColor),
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
              subtitle: const Text('Switch to selected environment'),
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

  void _applyConfiguration() {
    // Configure environment - this will automatically set the data source and profile
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to local development with mock data'),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }
}
