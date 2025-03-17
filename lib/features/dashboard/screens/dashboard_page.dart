import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';

class DashboardPage extends ConsumerWidget {
  final Function(int)? onNavigate;

  const DashboardPage({Key? key, this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardScreen(onNavigate: onNavigate);
  }
}
