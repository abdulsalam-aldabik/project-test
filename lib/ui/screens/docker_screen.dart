import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/docker_container.dart';
import '../../features/docker/providers/docker_containers_provider.dart';
import '../../core/services/service_providers.dart';

/// Screen for displaying Docker containers
class DockerScreen extends ConsumerWidget {
  const DockerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for containers
    final containersAsync = ref.watch(dockerContainersProvider);
    
    // Use real-time system resources from WebSocket if available, fallback to HTTP
    final realTimeResources = ref.watch(realTimeSystemResourcesProvider);
    final httpResources = ref.watch(systemResourcesProvider);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh containers
          await ref.read(refreshContainersProvider)();
          
          // Request fresh system resources via WebSocket
          final wsService = ref.read(webSocketServiceProvider);
          wsService.requestSystemResources();
        },
        child: Column(
          children: [
            // System resources - Prefer real-time WebSocket data, fallback to HTTP
            realTimeResources.when(
              data: (resources) => _buildSystemResources(context, AsyncData(resources)),
              loading: () => _buildSystemResources(context, httpResources),
              error: (_, __) => _buildSystemResources(context, httpResources),
            ),
            
            // Container list
            Expanded(
              child: containersAsync.when(
                data: (containers) => _buildContainerList(context, ref, containers),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Refresh containers
          await ref.read(refreshContainersProvider)();
          
          // Request fresh system resources via WebSocket
          final wsService = ref.read(webSocketServiceProvider);
          wsService.requestSystemResources();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
  
  Widget _buildSystemResources(BuildContext context, AsyncValue<Map<String, dynamic>> resourcesAsync) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: resourcesAsync.when(
          data: (resources) {
            final cpuUsage = resources['cpu_usage'] ?? 0.0;
            final memoryUsage = resources['memory_usage'] ?? 0.0;
            final diskUsage = resources['disk_usage'] ?? 0.0;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Resources',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildResourceIndicator(context, 'CPU', cpuUsage, Colors.blue),
                const SizedBox(height: 4),
                _buildResourceIndicator(context, 'Memory', memoryUsage, Colors.green),
                const SizedBox(height: 4),
                _buildResourceIndicator(context, 'Disk', diskUsage, Colors.orange),
              ],
            );
          },
          loading: () => const Center(
            child: SizedBox(
              height: 100,
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Text('Error loading resources: $error'),
          ),
        ),
      ),
    );
  }
  
  Widget _buildResourceIndicator(BuildContext context, String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            '${value.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
  
  Widget _buildContainerList(BuildContext context, WidgetRef ref, List<DockerContainer> containers) {
    // Check if all containers are error containers
    final bool allErrors = containers.isNotEmpty && 
                          containers.every((c) => c.state == 'error');
    
    if (allErrors && containers.length == 1) {
      // Show a more user-friendly error message
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading containers',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                containers.first.status,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () => ref.read(refreshContainersProvider)(),
            ),
          ],
        ),
      );
    }
    
    // Sort containers by name
    containers.sort((a, b) => a.name.compareTo(b.name));
    
    return ListView.builder(
      itemCount: containers.length,
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemBuilder: (context, index) {
        final container = containers[index];
        return _buildContainerCard(context, ref, container);
      },
    );
  }
  
  Widget _buildContainerCard(BuildContext context, WidgetRef ref, DockerContainer container) {
    final isRunning = container.isRunning;
    final isError = container.state == 'error';
    final statusColor = isError ? Colors.orange : (isRunning ? Colors.green : Colors.red);
    
    // Check if this container has a web UI
    final serviceUrl = AppConstants.dockerServices[container.name];
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isError ? Icons.warning_amber : Icons.circle,
                  color: statusColor,
                  size: isError ? 16 : 12,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    container.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isError ? Colors.orange : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (serviceUrl != null && !isError)
                  IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: () async {
                      final url = Uri.parse(serviceUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    tooltip: 'Open web interface',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${container.status}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isError ? Colors.orange : null,
                fontWeight: isError ? FontWeight.bold : null,
              ),
            ),
            if (!isError) // Only show image for non-error containers
              Text(
                'Image: ${container.image}',
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            
            // Only show actions for non-error containers
            if (!isError)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isRunning)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.stop, size: 16),
                      label: const Text('Stop'),
                      onPressed: () async {
                        final dockerApiService = ref.read(dockerApiServiceProvider);
                        await dockerApiService.stopContainer(container.id);
                        ref.refresh(dockerContainersProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Start'),
                      onPressed: () async {
                        final dockerApiService = ref.read(dockerApiServiceProvider);
                        await dockerApiService.startContainer(container.id);
                        ref.refresh(dockerContainersProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Restart'),
                    onPressed: () async {
                      final dockerApiService = ref.read(dockerApiServiceProvider);
                      await dockerApiService.restartContainer(container.id);
                      ref.refresh(dockerContainersProvider);
                    },
                  ),
                ],
              )
            else // Show refresh button for error containers
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                    onPressed: () => ref.read(refreshContainersProvider)(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
} 