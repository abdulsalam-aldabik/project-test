import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/responsive_builder.dart';
import '../widgets/side_menu.dart';
import 'dashboard_content.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({Key? key, this.onNavigate}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ResponsiveBuilder.isMobile(context)
          ? Drawer(
              child: SideMenu(
              onMainNavigation: widget.onNavigate,
              showMainNavigation: true,
            ))
          : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Side Menu - show only on tablet and desktop
            if (!ResponsiveBuilder.isMobile(context))
              Expanded(
                flex: 1,
                child: SideMenu(
                  onMainNavigation: widget.onNavigate,
                  showMainNavigation: false,
                ),
              ),

            // Main Content
            Expanded(
              flex: ResponsiveBuilder.isMobile(context) ? 4 : 3,
              child: DashboardContent(
                onMenuPressed: _openDrawer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
