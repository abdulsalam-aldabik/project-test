import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/docker_container.dart';
import '../../../core/services/service_providers.dart';

/// Provider for all Docker containers
final dockerContainersProvider = FutureProvider<List<DockerContainer>>((ref) async {
  final dockerApiService = ref.watch(dockerApiServiceProvider);
  return await dockerApiService.fetchContainers();
});

/// Provider for a specific container by name
final containerByNameProvider = Provider.family<DockerContainer?, String>((ref, name) {
  final containersAsyncValue = ref.watch(dockerContainersProvider);
  
  return containersAsyncValue.when(
    data: (containers) {
      try {
        return containers.firstWhere((container) => container.name == name);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for running containers only
final runningContainersProvider = Provider<List<DockerContainer>>((ref) {
  final containersAsyncValue = ref.watch(dockerContainersProvider);
  
  return containersAsyncValue.when(
    data: (containers) {
      return containers.where((container) => container.isRunning).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for system resources
final systemResourcesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dockerApiService = ref.watch(dockerApiServiceProvider);
  return await dockerApiService.getSystemResources();
});

/// Provider for refreshing containers (triggers a refresh)
final refreshContainersProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // This will force a refresh of the containers
    ref.refresh(dockerContainersProvider);
    ref.refresh(systemResourcesProvider);
  };
}); 