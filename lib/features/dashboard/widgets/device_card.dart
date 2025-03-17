import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class DeviceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final VoidCallback onToggle;

  const DeviceCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      color: isDarkTheme ? theme.cardColor : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? theme.colorScheme.primary.withOpacity(0.2) 
                        : theme.disabledColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
                    size: 24,
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (_) => onToggle(),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? isDarkTheme ? Colors.white : Colors.black87
                    : isDarkTheme ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDarkTheme ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 