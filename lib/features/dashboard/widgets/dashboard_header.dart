import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onMenuPressed;

  const DashboardHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          // Only show menu button on mobile
          if (MediaQuery.of(context).size.width < 1200)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
            ),

          // Dashboard title and welcome message
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Action buttons
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              // Implement notifications
            },
          ),
          const SizedBox(width: 8),

          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
