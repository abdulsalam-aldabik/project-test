import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ha_api_service.dart';
import 'docker_api_service.dart';
import 'websocket_service.dart';

/// Provider for the Home Assistant API service
final haApiServiceProvider = Provider<HAApiService>((ref) {
  final service = HAApiService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Provider for the Docker API service
final dockerApiServiceProvider = Provider<DockerApiService>((ref) {
  return DockerApiService();
});

/// Provider for the WebSocket service
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  
  // Connect when the service is created
  service.connect();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider for real-time system resources
final realTimeSystemResourcesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.systemResourcesStream;
}); 