import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

/// Screen for application settings
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // For wider screens, use a row layout with two columns
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column (2/3 width)
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    child: Column(
                      children: [
                        _buildSettingsSection(
                          context,
                          'General',
                          _buildGeneralSettings(context, ref),
                        ),
                        _buildSettingsSection(
                          context,
                          'Home Assistant',
                          _buildHomeAssistantSettings(context, ref),
                        ),
                        _buildSettingsSection(
                          context,
                          'About',
                          _buildAboutSection(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right column (1/3 width)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    color: Theme.of(context).colorScheme.surface,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Configure your application preferences and settings.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // For narrower screens, use a column layout
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Column(
                children: [
                  _buildSettingsSection(
                    context,
                    'General',
                    _buildGeneralSettings(context, ref),
                  ),
                  _buildSettingsSection(
                    context,
                    'Home Assistant',
                    _buildHomeAssistantSettings(context, ref),
                  ),
                  _buildSettingsSection(
                    context,
                    'About',
                    _buildAboutSection(context),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  /// Build a settings section with header and content
  Widget _buildSettingsSection(
      BuildContext context, String title, Widget content) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          content,
        ],
      ),
    );
  }

  /// Build general settings
  Widget _buildGeneralSettings(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Use dark theme'),
          value: true, // Theme.of(context).brightness == Brightness.dark,
          onChanged: (value) {
            // Toggle theme
          },
        ),
        ListTile(
          title: const Text('Language'),
          subtitle: const Text('English'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Show language selection
          },
        ),
        ListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Configure notifications'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Show notification settings
          },
        ),
      ],
    );
  }

  /// Build Home Assistant settings
  Widget _buildHomeAssistantSettings(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          title: const Text('API Connection'),
          subtitle: const Text('Configure Home Assistant API connection'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Show API settings
          },
        ),
        ListTile(
          title: const Text('Entity Filter'),
          subtitle: const Text('Configure which entities to display'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Show entity filter settings
          },
        ),
      ],
    );
  }

  /// Build about section
  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Version'),
          subtitle: Text(AppConstants.appVersion),
        ),
        ListTile(
          title: const Text('Source Code'),
          subtitle: const Text('View on GitHub'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            // Open GitHub URL
          },
        ),
        ListTile(
          title: const Text('License'),
          subtitle: const Text('MIT License'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Show license information
          },
        ),
      ],
    );
  }
}
