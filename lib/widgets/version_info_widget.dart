import 'package:flutter/material.dart';
import 'package:pantryready/services/version_service.dart';

/// Widget to display app version information
class VersionInfoWidget extends StatelessWidget {
  const VersionInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('App Name', VersionService.appName),
            _buildInfoRow('Version', VersionService.displayVersion),
            _buildInfoRow('Build Number', VersionService.buildNumber),
            _buildInfoRow('Environment', _getEnvironmentDisplay()),
            _buildInfoRow('Data Source', _getDataSourceDisplay()),
            const SizedBox(height: 8),
            const Text(
              'Version tracking helps identify issues and track app usage.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  String _getEnvironmentDisplay() {
    final env = VersionService.versionInfo['environment'] ?? 'unknown';
    switch (env) {
      case 'production':
        return 'Production';
      case 'debug':
        return 'Debug';
      case 'profile':
        return 'Profile';
      default:
        return env;
    }
  }

  String _getDataSourceDisplay() {
    final source = VersionService.versionInfo['data_source'] ?? 'unknown';
    switch (source) {
      case 'mock':
        return 'Mock Data';
      case 'local':
        return 'Local Storage';
      case 'firestore':
        return 'Firestore';
      default:
        return source;
    }
  }
}
