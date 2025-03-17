import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:html' as html;
import '../constants/app_constants.dart';
import 'dart:math' as math;

/// Service for handling WebSocket connections
class WebSocketService {
  /// The WebSocket channel
  WebSocketChannel? _channel;
  
  /// Stream controller for system resources
  final _systemResourcesController = StreamController<Map<String, dynamic>>.broadcast();
  
  /// Stream for system resources
  Stream<Map<String, dynamic>> get systemResourcesStream => _systemResourcesController.stream;
  
  /// Flag to track connection status
  bool _isConnected = false;
  
  /// Get connection status
  bool get isConnected => _isConnected;
  
  /// Retry counter to limit reconnection attempts
  int _retryCount = 0;
  
  /// Maximum number of retry attempts
  static const int _maxRetries = 5;
  
  /// Base delay for exponential backoff (in seconds)
  static const int _baseRetryDelay = 2;
  
  /// Timer for throttling connection attempts
  Timer? _reconnectTimer;
  
  /// Connect to the WebSocket server
  void connect() {
    // Cancel any pending reconnect timer
    _reconnectTimer?.cancel();
    
    // If we've reached the max retries, stop trying for a while
    if (_retryCount >= _maxRetries) {
      if (kDebugMode) {
        print('Max WebSocket reconnection attempts reached. Will try again in 30 seconds.');
      }
      
      _reconnectTimer = Timer(const Duration(seconds: 30), () {
        _retryCount = 0;
        connect();
      });
      
      return;
    }
    
    try {
      // Convert HTTP URL to WebSocket URL (ws:// or wss://)
      final wsUrl = _getWebSocketUrl();
      
      if (kDebugMode) {
        print('Connecting to WebSocket: $wsUrl (attempt #${_retryCount + 1})');
      }
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Listen for messages
      _channel!.stream.listen(
        (dynamic message) {
          _handleMessage(message);
          // Reset retry count on successful message
          _retryCount = 0;
          _isConnected = true;
        },
        onError: (error) {
          if (kDebugMode) {
            print('WebSocket error: $error');
          }
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          if (kDebugMode) {
            print('WebSocket connection closed');
          }
          _isConnected = false;
          _scheduleReconnect();
        },
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to WebSocket: $e');
      }
      _isConnected = false;
      _scheduleReconnect();
    }
  }
  
  /// Schedule a reconnection attempt with exponential backoff
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    
    // Increment retry counter
    _retryCount++;
    
    // Calculate delay with exponential backoff: baseDelay * 2^(retryCount-1) (capped at 60 seconds)
    final delay = math.min(
      _baseRetryDelay * math.pow(2, _retryCount - 1).round(), 
      60
    );
    
    if (kDebugMode) {
      print('Scheduling WebSocket reconnection in $delay seconds (attempt #$_retryCount)');
    }
    
    _reconnectTimer = Timer(Duration(seconds: delay), connect);
  }
  
  /// Get the appropriate WebSocket URL based on environment
  String _getWebSocketUrl() {
    final apiUrl = AppConstants.statusApiUrl;
    String wsUrl;
    
    // If we're using a relative URL (starts with '/'), we need to construct the full WebSocket URL
    if (apiUrl.startsWith('/')) {
      // Get current page location
      final location = html.window.location;
      final protocol = location.protocol == 'https:' ? 'wss:' : 'ws:';
      final host = location.host; // includes hostname and port
      
      // Replace /api with /ws for WebSocket endpoint
      final path = apiUrl.replaceFirst('/api', '/ws');
      
      // Ensure path ends with a slash
      final normalizedPath = path.endsWith('/') ? path : '$path/';
      
      wsUrl = '$protocol//$host$normalizedPath';
    } else {
      // For absolute URLs, just replace http with ws
      wsUrl = apiUrl.replaceFirst('http', 'ws');
      
      // Ensure URL ends with a slash
      if (!wsUrl.endsWith('/')) {
        wsUrl = '$wsUrl/';
      }
    }
    
    if (kDebugMode) {
      print('Converting $apiUrl to WebSocket URL: $wsUrl');
    }
    
    return wsUrl;
  }
  
  /// Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      if (kDebugMode) {
        print('Received WebSocket message: ${message.toString().substring(0, min(50, message.toString().length))}...');
      }
      
      final Map<String, dynamic> data = jsonDecode(message);
      final String messageType = data['type'];
      
      switch (messageType) {
        case 'system_resources':
          final resourcesData = data['data'];
          _systemResourcesController.add(resourcesData);
          break;
        default:
          if (kDebugMode) {
            print('Unknown message type: $messageType');
          }
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling WebSocket message: $e');
      }
    }
  }
  
  /// Request system resources update
  void requestSystemResources() {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'get_resources'
      }));
    } else {
      if (kDebugMode) {
        print('Cannot request resources - WebSocket not connected. Attempting to reconnect...');
      }
      connect();
    }
  }
  
  /// Disconnect from the WebSocket server
  void disconnect() {
    _reconnectTimer?.cancel();
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
    _retryCount = 0;
  }
  
  /// Clean up resources
  void dispose() {
    disconnect();
    _systemResourcesController.close();
  }
  
  /// Helper function to get minimum of two values
  int min(int a, int b) => a < b ? a : b;
  
  /// Helper for math functions
  static final math = _MathHelper();
}

/// Helper class for math functions that aren't directly imported
class _MathHelper {
  double pow(num base, int exponent) => base.toDouble() * exponent.toDouble();
  int min(int a, int b) => a < b ? a : b;
} 