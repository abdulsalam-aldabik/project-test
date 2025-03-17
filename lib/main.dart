import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/env_config.dart';
import 'core/constants/app_constants.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'dart:async';
import 'core/services/service_providers.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration before creating the app
  EnvConfig.initialize();
  
  // Catches Flutter-specific errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  
  // Catches all other errors outside of Flutter
  runZonedGuarded(() {
    runApp(
      // Wrap the entire app with ProviderScope for Riverpod
      const ProviderScope(
        child: MyApp(),
      ),
    );
  }, (error, stackTrace) {
    print('Caught exception outside of Flutter: $error');
    print('Stack trace: $stackTrace');
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    
    // Initialize WebSocket connection as soon as the app starts
    Future.microtask(() {
      final haApiService = ref.read(haApiServiceProvider);
      print('Initializing WebSocket connection at app startup...');
      
      haApiService.connectWebSocket().then((_) {
        haApiService.subscribeToEvents('state_changed');
        print('WebSocket successfully connected at app startup');
      }).catchError((e) {
        print('Error connecting to WebSocket at startup: $e');
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.getDarkTheme(),
      themeMode: ThemeMode.dark,
      routes: {
        '/': (context) => const HomeScreen(),
      },
      initialRoute: '/', // Changed to start with the home screen
      debugShowCheckedModeBanner: false,
    );
  }
}
