import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

import '../constants/app_constants.dart';
import '../models/ha_entity.dart';
import 'api_client.dart';

/// Service for interacting with the Home Assistant API
class HAApiService {
  /// Secure storage for token
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  /// WebSocket channel
  WebSocketChannel? _wsChannel;
  
  /// Stream controller for websocket events
  final _wsEventController = StreamController<dynamic>.broadcast();
  
  /// API client for making HTTP requests - initialize immediately with default token
  ApiClient _apiClient = ApiClient(
    baseUrl: AppConstants.homeAssistantApiUrl,
    defaultHeaders: {
      'Authorization': 'Bearer ${AppConstants.defaultHAToken}',
      'Content-Type': 'application/json',
    },
    timeout: const Duration(seconds: 10), // Set a reasonable timeout
  );
  
  /// Stream of websocket events
  Stream<dynamic> get wsEvents => _wsEventController.stream;
  
  /// Constructor
  HAApiService() {
    // Initialize the token if not already set
    _initializeToken();
    if (kDebugMode) {
      print('Home Assistant API URL: ${AppConstants.homeAssistantApiUrl}');
    }
  }
  
  /// Initialize the token with the default value if none exists
  Future<void> _initializeToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      await saveToken(AppConstants.defaultHAToken);
    } else {
      // Update the API client with the stored token
      _updateApiClient(token);
    }
  }
  
  /// Update the API client with the given token
  void _updateApiClient(String token) {
    _apiClient = ApiClient(
      baseUrl: AppConstants.homeAssistantApiUrl,
      defaultHeaders: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      timeout: const Duration(seconds: 10), // Set a reasonable timeout
    );
  }
  
  /// Get the Home Assistant token
  Future<String> getToken() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    return token ?? AppConstants.defaultHAToken;
  }
  
  /// Save the Home Assistant token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
    // Update the API client with the new token
    _updateApiClient(token);
  }
  
  /// Clear the Home Assistant token
  Future<void> clearToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  /// Fetch all states from Home Assistant
  Future<List<HAEntity>> fetchStates() async {
    try {
      if (kDebugMode) {
        print('Fetching states from ${AppConstants.homeAssistantApiUrl}/states');
        print('Using token: ${AppConstants.defaultHAToken.substring(0, 20)}...');
      }
      
      final response = await _apiClient.get('/states');
      
      if (kDebugMode) {
        print('Response type: ${response.runtimeType}');
        if (response is String) {
          print('First 100 chars: ${response.substring(0, math.min(100, response.length))}');
        } else if (response is List) {
          print('List length: ${response.length}');
        }
      }
      
      if (response is List) {
        return response.map((json) => HAEntity.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response is String && response.isNotEmpty) {
        try {
          final List<dynamic> parsed = jsonDecode(response) as List<dynamic>;
          return parsed.map((json) => HAEntity.fromJson(json as Map<String, dynamic>)).toList();
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing JSON: $e');
          }
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching states: $e');
      }
      throw Exception('Failed to load states: $e');
    }
  }
  
  /// Fetch a specific entity state
  Future<HAEntity> fetchEntityState(String entityId) async {
    try {
      final response = await _apiClient.get('/states/$entityId');
      return HAEntity.fromJson(response);
    } catch (e) {
      print('Error fetching entity state: $e');
      throw Exception('Failed to load entity state: $e');
    }
  }
  
  /// Call a service in Home Assistant
  Future<bool> callService(String domain, String service, Map<String, dynamic> data) async {
    try {
      await _apiClient.post('/services/$domain/$service', body: data);
      return true;
    } catch (e) {
      print('Error calling service: $e');
      return false;
    }
  }
  
  /// Connect to the WebSocket API
  Future<void> connectWebSocket() async {
    final token = await getToken();
    
    // Close existing connection if any
    await disconnectWebSocket();
    
    try {
      _wsChannel = WebSocketChannel.connect(
        Uri.parse(AppConstants.homeAssistantWebSocketUrl),
      );
      
      // Send authentication message
      _wsChannel!.sink.add(jsonEncode({
        'type': 'auth',
        'access_token': token,
      }));
      
      // Listen for messages
      _wsChannel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _wsEventController.add(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _wsEventController.addError(error);
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }
  
  /// Disconnect from the WebSocket API
  Future<void> disconnectWebSocket() async {
    await _wsChannel?.sink.close();
    _wsChannel = null;
  }
  
  /// Subscribe to events
  void subscribeToEvents(String eventType) {
    if (_wsChannel == null) {
      throw Exception('WebSocket not connected');
    }
    
    final int id = DateTime.now().millisecondsSinceEpoch;
    
    _wsChannel!.sink.add(jsonEncode({
      'id': id,
      'type': 'subscribe_events',
      'event_type': eventType,
    }));
  }
  
  /// Dispose the service
  void dispose() {
    disconnectWebSocket();
    _wsEventController.close();
  }
} 