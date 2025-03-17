import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_item_model.dart';
import '../../../core/constants/app_constants.dart';

// Provider to track the selected main navigation item
final selectedMenuItemProvider = StateProvider<String>((ref) => 'Dashboard');

class SideMenu extends ConsumerWidget {
  final Function(int)? onMainNavigation;
  final bool showMainNavigation;

  const SideMenu({
    super.key,
    this.onMainNavigation,
    this.showMainNavigation = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMenuItem = ref.watch(selectedMenuItemProvider);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkTheme ? Theme.of(context).colorScheme.surface : Colors.white,
      width: 250,
      child: Column(
        children: [
          // Logo and app name
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            height: 100,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.home_work,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              children: [
                // Dashboard section menu items
                if (showMainNavigation) ...[
                  _buildMainNavItem(
                    context,
                    ref,
                    MenuItem(
                      title: 'Dashboard',
                      icon: Icons.dashboard,
                      isActive: selectedMenuItem == 'Dashboard',
                    ),
                    index: 0,
                  ),
                  _buildMainNavItem(
                    context,
                    ref,
                    MenuItem(
                      title: 'Home Assistant',
                      icon: Icons.home_work,
                      isActive: selectedMenuItem == 'Home Assistant',
                    ),
                    index: 1,
                  ),
                  _buildMainNavItem(
                    context,
                    ref,
                    MenuItem(
                      title: 'Docker',
                      icon: Icons.storage,
                      isActive: selectedMenuItem == 'Docker',
                    ),
                    index: 2,
                  ),
                ] else ...[
                  // Dashboard internal menu items when in dashboard view
                  _buildMenuItem(
                    context,
                    ref,
                    MenuItem(
                      title: 'Dashboard',
                      icon: Icons.dashboard,
                      isActive: selectedMenuItem == 'Dashboard',
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    MenuItem(
                      title: 'Devices',
                      icon: Icons.devices,
                      isActive: selectedMenuItem == 'Devices',
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    MenuItem(
                      title: 'Rooms',
                      icon: Icons.meeting_room_outlined,
                      isActive: selectedMenuItem == 'Rooms',
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    MenuItem(
                      title: 'Statistics',
                      icon: Icons.bar_chart,
                      isActive: selectedMenuItem == 'Statistics',
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),

                // Common settings items
                _buildMenuItem(
                  context,
                  ref,
                  MenuItem(
                    title: 'Profile',
                    icon: Icons.person_outline,
                    isActive: selectedMenuItem == 'Profile',
                  ),
                ),
                _buildMainNavItem(
                  context,
                  ref,
                  MenuItem(
                    title: 'Settings',
                    icon: Icons.settings,
                    isActive: selectedMenuItem == 'Settings',
                  ),
                  index: 3,
                ),
              ],
            ),
          ),

          // Bottom info section
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 18),
                      onPressed: () {
                        // Handle logout
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, WidgetRef ref, MenuItem item) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        item.icon,
        color:
            item.isActive ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: item.isActive
              ? Theme.of(context).colorScheme.primary
              : isDarkTheme
                  ? Colors.white70
                  : Colors.black87,
          fontWeight: item.isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      selected: item.isActive,
      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      onTap: () {
        ref.read(selectedMenuItemProvider.notifier).state = item.title;
      },
    );
  }

  Widget _buildMainNavItem(BuildContext context, WidgetRef ref, MenuItem item,
      {required int index}) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        item.icon,
        color:
            item.isActive ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: item.isActive
              ? Theme.of(context).colorScheme.primary
              : isDarkTheme
                  ? Colors.white70
                  : Colors.black87,
          fontWeight: item.isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      selected: item.isActive,
      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      onTap: () {
        ref.read(selectedMenuItemProvider.notifier).state = item.title;

        // Trigger navigation to the appropriate section
        if (onMainNavigation != null) {
          onMainNavigation!(index);

          // Close drawer if we're in a drawer
          if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
            Navigator.pop(context);
          }
        }
      },
    );
  }
}
