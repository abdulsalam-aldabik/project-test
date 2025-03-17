import '../constants/app_constants.dart';
import '../models/docker_container.dart';
import 'api_client.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

/// Service for interacting with the Docker Status API
class DockerApiService {
  /// API client for making HTTP requests
  final ApiClient _apiClient;

  /// Constructor
  DockerApiService() : _apiClient = ApiClient(baseUrl: AppConstants.statusApiUrl);
  
  /// Fetch all Docker containers
  Future<List<DockerContainer>> fetchContainers() async {
    try {
      if (kDebugMode) {
        print('Fetching containers from ${AppConstants.statusApiUrl}/containers');
      }
      
      final response = await _apiClient.get('/containers');
      
      if (kDebugMode) {
        print('Response type: ${response.runtimeType}');
        final previewLength = math.min(200, response.toString().length);
        print('Response first $previewLength chars: ${response.toString().substring(0, previewLength)}');
      }
      
      if (response is List) {
        if (kDebugMode) {
          print('Processing list response with ${response.length} items');
        }
        
        return response.map((json) {
          if (kDebugMode) {
            print('Container item: $json');
          }
          try {
            return DockerContainer.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing container: $e');
            }
            // Return a placeholder container instead of throwing
            return DockerContainer(
              id: 'error-${DateTime.now().millisecondsSinceEpoch}',
              name: 'Error parsing container',
              image: 'unknown',
              state: 'error',
              status: 'Parse error: ${e.toString().substring(0, math.min(50, e.toString().length))}',
              ports: [],
              created: DateTime.now().toString(),
            );
          }
        }).toList();
      } else if (response is Map && response.containsKey('containers') && response['containers'] is List) {
        // Handle case where response is wrapped in a containers object
        final containersList = response['containers'] as List;
        if (kDebugMode) {
          print('Processing wrapped list with ${containersList.length} items');
        }
        
        return containersList.map((json) {
          try {
            return DockerContainer.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing container in wrapped list: $e');
            }
            return DockerContainer(
              id: 'error-${DateTime.now().millisecondsSinceEpoch}',
              name: 'Error parsing container',
              image: 'unknown',
              state: 'error',
              status: 'Parse error',
              ports: [],
              created: DateTime.now().toString(),
            );
          }
        }).toList();
      } else if (response is String) {
        // Check if the response is HTML
        final responseStr = response.toString().trim();
        if (responseStr.startsWith('<!DOCTYPE') || responseStr.startsWith('<html')) {
          if (kDebugMode) {
            print('Received HTML response instead of JSON containers');
          }
          
          // Return a single error container instead of throwing
          return [
            DockerContainer(
              id: 'error-html',
              name: 'API Error',
              image: 'error',
              state: 'error',
              status: 'Server returned HTML instead of JSON',
              ports: [],
              created: DateTime.now().toString(),
            )
          ];
        }
        
        // Try to parse as JSON if it's a string
        try {
          final parsed = jsonDecode(responseStr);
          if (kDebugMode) {
            print('Parsed string response to: ${parsed.runtimeType}');
          }
          
          if (parsed is List) {
            return parsed.map((json) => DockerContainer.fromJson(json as Map<String, dynamic>)).toList();
          } else if (parsed is Map && parsed.containsKey('containers') && parsed['containers'] is List) {
            final containersList = parsed['containers'] as List;
            return containersList.map((json) => DockerContainer.fromJson(json as Map<String, dynamic>)).toList();
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing JSON string: $e');
            print('String content: ${responseStr.substring(0, math.min(200, responseStr.length))}');
          }
          
          // Return an error container
          return [
            DockerContainer(
              id: 'error-json',
              name: 'JSON Parse Error',
              image: 'error',
              state: 'error',
              status: 'Could not parse server response',
              ports: [],
              created: DateTime.now().toString(),
            )
          ];
        }
      }
      
      if (kDebugMode) {
        print('Unexpected response format: ${response.runtimeType}');
        print('Response content: $response');
      }
      
      // Return a single error container instead of throwing
      return [
        DockerContainer(
          id: 'error-format',
          name: 'Format Error',
          image: 'error',
          state: 'error',
          status: 'Unexpected response format: ${response?.runtimeType}',
          ports: [],
          created: DateTime.now().toString(),
        )
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching containers: $e');
      }
      
      // Return a single error container instead of throwing
      return [
        DockerContainer(
          id: 'error-exception',
          name: 'Connection Error',
          image: 'error',
          state: 'error',
          status: 'Error: ${e.toString().substring(0, math.min(50, e.toString().length))}',
          ports: [],
          created: DateTime.now().toString(),
        )
      ];
    }
  }
  
  /// Fetch a specific Docker container by name
  Future<DockerContainer> fetchContainerByName(String name) async {
    try {
      final response = await _apiClient.get('/containers/$name');
      return DockerContainer.fromJson(response);
    } catch (e) {
      print('Error fetching container: $e');
      throw Exception('Failed to load container: $e');
    }
  }
  
  /// Start a Docker container
  Future<bool> startContainer(String containerId) async {
    try {
      await _apiClient.post('/containers/$containerId/start');
      return true;
    } catch (e) {
      print('Error starting container: $e');
      return false;
    }
  }
  
  /// Stop a Docker container
  Future<bool> stopContainer(String containerId) async {
    try {
      await _apiClient.post('/containers/$containerId/stop');
      return true;
    } catch (e) {
      print('Error stopping container: $e');
      return false;
    }
  }
  
  /// Restart a Docker container
  Future<bool> restartContainer(String containerId) async {
    try {
      await _apiClient.post('/containers/$containerId/restart');
      return true;
    } catch (e) {
      print('Error restarting container: $e');
      return false;
    }
  }
  
  /// Get Docker system information
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final response = await _apiClient.get('/system/info');
      return response is Map ? Map<String, dynamic>.from(response) : {};
    } catch (e) {
      print('Error fetching system info: $e');
      throw Exception('Failed to load system info: $e');
    }
  }
  
  /// Get Docker system resources usage
  Future<Map<String, dynamic>> getSystemResources() async {
    try {
      if (kDebugMode) {
        print('Fetching system resources from ${AppConstants.statusApiUrl}/system/resources');
      }
      
      final response = await _apiClient.get('/system/resources');
      
      if (kDebugMode) {
        print('System resources response type: ${response.runtimeType}');
        final previewLength = math.min(100, response.toString().length);
        print('System resources first $previewLength chars: ${response.toString().substring(0, previewLength)}');
      }
      
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is Map) {
        return Map<String, dynamic>.from(response);
      } else if (response is String) {
        // Check if the response is HTML (starts with <!DOCTYPE or <html)
        final responseStr = response.toString().trim();
        if (responseStr.startsWith('<!DOCTYPE') || responseStr.startsWith('<html')) {
          if (kDebugMode) {
            print('Received HTML response instead of JSON');
          }
          // Return default values instead of throwing an exception
          return {
            'error': 'Server returned HTML instead of JSON',
            'cpu_usage': 0,
            'memory_usage': 0,
            'disk_usage': 0,
            'html_received': true
          };
        }
        
        try {
          // Clean the string if needed
          String cleanJson = responseStr;
          final dynamic decoded = jsonDecode(cleanJson);
          
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          } else {
            if (kDebugMode) {
              print('Decoded JSON is not a map: ${decoded.runtimeType}');
            }
            return {'error': 'Invalid format', 'data': decoded};
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing system resources JSON: $e');
            print('Raw response first 200 chars: ${responseStr.substring(0, math.min(200, responseStr.length))}');
          }
          return {
            'error': 'Failed to parse response',
            'message': e.toString(),
            'cpu_usage': 0,
            'memory_usage': 0,
            'disk_usage': 0
          };
        }
      } else {
        if (kDebugMode) {
          print('Unexpected system resources format: ${response.runtimeType}');
          print('Response content: $response');
        }
        return {
          'error': 'Unexpected format',
          'type': response.runtimeType.toString(),
          'cpu_usage': 0,
          'memory_usage': 0,
          'disk_usage': 0
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching system resources: $e');
      }
      return {
        'error': 'Exception caught',
        'message': e.toString(),
        'cpu_usage': 0,
        'memory_usage': 0,
        'disk_usage': 0
      };
    }
  }
} 