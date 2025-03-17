import 'dart:html' as html;

/// Environment configuration for the application
class EnvConfig {
  /// The base URL for the Home Assistant API
  final String homeAssistantBaseUrl;
  
  /// The base URL for the status API
  final String statusApiBaseUrl;
  
  /// The default token for Home Assistant
  final String defaultHAToken;

  /// Private constructor
  EnvConfig._({
    required this.homeAssistantBaseUrl,
    required this.statusApiBaseUrl,
    required this.defaultHAToken,
  });

  /// Current environment configuration
  static EnvConfig get current => _instance;
  
  /// Singleton instance
  static late final EnvConfig _instance;
  
  /// Initialize the environment configuration
  static void initialize() {
    // Get the current URL to determine environment
    final locationUri = Uri.parse(html.window.location.href);
    final hostname = locationUri.host;
    final port = locationUri.port;
    final isLocalhost = hostname == 'localhost' || hostname.startsWith('127.0.0.1');
    final isHttps = locationUri.scheme == 'https';
    
    // Determine Status API URL based on environment
    // 1. Try to get from environment variable if in Docker (not directly available in browser)
    // 2. Use hostname-based URL for development
    // 3. Use docker service name for Docker Compose networking
    String statusApiUrl;
    
    // In production Docker container, use the service name from Docker Compose
    if (hostname.contains('192.168.0.207') || port == 8086) {
      // Running in production container or accessing via production URL
      // Use relative URLs for browser access instead of Docker network names
      statusApiUrl = '/api';
    } else if (isLocalhost) {
      // Local development - use the specific local environment
      statusApiUrl = 'http://192.168.0.207:4000';
    } else {
      // Other environments - assume relative path
      statusApiUrl = '/api';
    }
    
    // Initialize the config with the appropriate URLs
    _instance = EnvConfig._(
      homeAssistantBaseUrl: 'http://100.76.141.29:8085',
      statusApiBaseUrl: statusApiUrl,
      defaultHAToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIyMmMyNTYxNjFlZTM0ZThjOGMyYzZjYzRmZDJiN2YzNCIsImlhdCI6MTc0MTg0MDcxNSwiZXhwIjoyMDU3MjAwNzE1fQ.A7U56UxBuDFNyMiS8mxydNDVh25XMDbEn4sAK2htTOU',
    );
  }
} 