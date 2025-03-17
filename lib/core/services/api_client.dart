import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// API client for making HTTP requests
class ApiClient {
  /// Base URL for the API
  final String baseUrl;
  
  /// Default headers to include in all requests
  final Map<String, String> defaultHeaders;
  
  /// Timeout for HTTP requests
  final Duration timeout;

  /// Constructor
  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
    },
    this.timeout = const Duration(seconds: 30),
  });

  /// Make a GET request
  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      if (kDebugMode) {
        print('Making GET request to: $url');
      }
      
      final response = await http.get(
        url,
        headers: {...defaultHeaders, ...?headers},
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e, 'GET', path);
      rethrow;
    }
  }

  /// Make a POST request
  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final encodedBody = body != null ? jsonEncode(body) : null;
      
      if (kDebugMode) {
        print('Making POST request to: $url');
        if (body != null) {
          print('Body: $encodedBody');
        }
      }
      
      final response = await http.post(
        url,
        headers: {...defaultHeaders, ...?headers},
        body: encodedBody,
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e, 'POST', path);
      rethrow;
    }
  }

  /// Make a PUT request
  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final encodedBody = body != null ? jsonEncode(body) : null;
      
      final response = await http.put(
        url,
        headers: {...defaultHeaders, ...?headers},
        body: encodedBody,
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e, 'PUT', path);
      rethrow;
    }
  }

  /// Make a DELETE request
  Future<dynamic> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.delete(
        url,
        headers: {...defaultHeaders, ...?headers},
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e, 'DELETE', path);
      rethrow;
    }
  }

  /// Handle the HTTP response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final contentType = response.headers['content-type'] ?? '';
    
    if (kDebugMode) {
      print('Response status code: $statusCode');
      print('Response content type: $contentType');
      print('Response body length: ${response.body.length}');
    }
    
    if (statusCode >= 200 && statusCode < 300) {
      try {
        if (response.body.isEmpty) {
          return null;
        }
        
        // Check if response is HTML instead of JSON
        final bodyStart = response.body.trim();
        if (contentType.contains('text/html') || 
            bodyStart.startsWith('<!DOCTYPE') || 
            bodyStart.startsWith('<html')) {
          
          if (kDebugMode) {
            print('Received HTML response when expecting JSON');
            print('First 100 chars: ${bodyStart.substring(0, bodyStart.length < 100 ? bodyStart.length : 100)}');
          }
          
          // Return the raw body for further processing instead of trying to parse JSON
          return response.body;
        }
        
        return jsonDecode(response.body);
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding response: $e');
          print('Response body preview: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
        }
        return response.body;
      }
    } else {
      _handleErrorResponse(response);
    }
  }

  /// Handle an error response
  void _handleErrorResponse(http.Response response) {
    final statusCode = response.statusCode;
    final contentType = response.headers['content-type'] ?? '';
    String message;
    
    if (kDebugMode) {
      print('Error response status code: $statusCode');
      print('Error response content type: $contentType');
    }
    
    try {
      if (response.body.isNotEmpty) {
        // Check if response is HTML
        if (contentType.contains('text/html') || 
            response.body.trim().startsWith('<!DOCTYPE') || 
            response.body.trim().startsWith('<html')) {
          
          message = 'Received HTML response: Status code $statusCode';
          if (kDebugMode) {
            print('HTML response preview: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}');
          }
        } else {
          try {
            final body = jsonDecode(response.body);
            message = body['message'] ?? body['error'] ?? 'Unknown error';
          } catch (e) {
            message = 'Failed to parse error response: $e';
          }
        }
      } else {
        message = 'Empty response with status code: $statusCode';
      }
    } catch (e) {
      message = response.body.isEmpty ? 'Unknown error' : response.body;
    }
    
    if (kDebugMode) {
      print('API Error (${response.statusCode}): $message');
      print('URL: ${response.request?.url}');
    }
    
    if (statusCode == 401) {
      throw UnauthorizedException(message);
    } else if (statusCode == 403) {
      throw ForbiddenException(message);
    } else if (statusCode == 404) {
      throw NotFoundException(message);
    } else if (statusCode >= 500) {
      throw ServerException(message);
    } else {
      throw ApiException(message, statusCode);
    }
  }

  /// Handle an error (not from a response)
  void _handleError(Object error, String method, String path) {
    if (kDebugMode) {
      print('API Error in $method $path: $error');
    }
  }
}

/// Base class for API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ApiException: $message (Status code: $statusCode)';
}

/// Exception for 401 Unauthorized responses
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
  
  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception for 403 Forbidden responses
class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
  
  @override
  String toString() => 'ForbiddenException: $message';
}

/// Exception for 404 Not Found responses
class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
  
  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception for 500+ server errors
class ServerException extends ApiException {
  ServerException(String message) : super(message, 500);
  
  @override
  String toString() => 'ServerException: $message';
} 