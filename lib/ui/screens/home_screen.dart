import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import 'home_assistant_screen.dart';
import 'docker_screen.dart';
import 'settings_screen.dart';
import '../../features/dashboard/screens/dashboard_page.dart';
import '../../features/dashboard/widgets/side_menu.dart';
import '../../features/dashboard/widgets/responsive_builder.dart';

/// The main screen of the application
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of main sections in the app
  final List<String> _sections = [
    'Dashboard',
    'Home Assistant',
    'Docker',
    'Settings',
  ];

  // Change the selected section
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Update the selected menu item in the provider
      ref.read(selectedMenuItemProvider.notifier).state = _sections[index];
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDashboard = _selectedIndex == 0;
    final bool isMobile = ResponsiveBuilder.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: isDashboard
          ? null
          : AppBar(
              title: Text(_sections[_selectedIndex]),
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: isMobile
                  ? IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: _openDrawer,
                    )
                  : null,
            ),
      drawer: isMobile
          ? Drawer(
              child: SideMenu(
                onMainNavigation: _onItemTapped,
                showMainNavigation: true,
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Side Menu - show only on tablet and desktop, and not in dashboard mode
            if (!isMobile && !isDashboard)
              Expanded(
                flex: 1,
                child: SideMenu(
                  onMainNavigation: _onItemTapped,
                  showMainNavigation: true,
                ),
              ),

            // Main Content
            Expanded(
              flex: (!isMobile && !isDashboard) ? 4 : 1,
              child: _buildBody(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isMobile && !isDashboard
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(_getIconForIndex(0)),
                  label: _sections[0],
                ),
                BottomNavigationBarItem(
                  icon: Icon(_getIconForIndex(1)),
                  label: _sections[1],
                ),
                BottomNavigationBarItem(
                  icon: Icon(_getIconForIndex(2)),
                  label: _sections[2],
                ),
                BottomNavigationBarItem(
                  icon: Icon(_getIconForIndex(3)),
                  label: _sections[3],
                ),
              ],
            )
          : null,
    );
  }

  // Get icon for each section
  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.home_work;
      case 2:
        return Icons.storage;
      case 3:
        return Icons.settings;
      default:
        return Icons.dashboard;
    }
  }

  // Build the body based on the selected section
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage(onNavigate: _onItemTapped);
      case 1:
        return const HomeAssistantScreen();
      case 2:
        return const DockerScreen();
      case 3:
        return const SettingsScreen();
      default:
        return DashboardPage(onNavigate: _onItemTapped);
    }
  }
}
