import 'env_config.dart';

/// Constants used throughout the app
class AppConstants {
  // Version information
  static const String appVersion = "0.0.4";
  static const String appName = "Home Dashboard";
  
  // API endpoints and URLs
  static String get homeAssistantBaseUrl => EnvConfig.current.homeAssistantBaseUrl;
  static String get homeAssistantApiUrl => '$homeAssistantBaseUrl/api';
  static String get homeAssistantWebSocketUrl => '${homeAssistantBaseUrl.replaceFirst('http', 'ws')}/api/websocket';
  
  // Home Assistant token
  static String get defaultHAToken => EnvConfig.current.defaultHAToken;
  
  // Status API endpoint
  static String get statusApiUrl => EnvConfig.current.statusApiBaseUrl;
  
  // Docker service URLs with default ports from your docker-compose
  static final Map<String, String> dockerServices = {
    'jellyfin': 'http://100.76.141.29:8097',
    'qbittorrent': 'http://100.76.141.29:8080',
    'sonarr': 'http://100.76.141.29:8989',
    'radarr': 'http://100.76.141.29:7878',
    'prowlarr': 'http://100.76.141.29:9696',
    'jellyseerr': 'http://100.76.141.29:5055',
    'bazarr': 'http://100.76.141.29:6767',
    'nginx-proxy-manager': 'http://100.76.141.29:81',
    'tdarr': 'http://100.76.141.29:8265',
  };
  
  // Local storage keys
  static const String tokenKey = 'home_assistant_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';
  
  // Animation durations
  static const Duration shortAnimDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimDuration = Duration(milliseconds: 350);
  static const Duration longAnimDuration = Duration(milliseconds: 500);
  
  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  
  // Card dimensions
  static const double cardBorderRadius = 16.0;
  static const double cardPadding = 16.0;
  
  // Navigation
  static const double navDrawerWidth = 280.0;
  
  // Default image placeholders
  static const String placeholderImageUrl = 'assets/images/placeholder.png';
} 