import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/ha_entity.dart';
import '../../features/home_assistant/providers/ha_entities_provider.dart';

/// Screen for displaying Home Assistant entities
class HomeAssistantScreen extends ConsumerWidget {
  const HomeAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for entities
    final entitiesAsync = ref.watch(haEntitiesProvider);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh entities
          await ref.read(refreshEntitiesProvider)();
        },
        child: entitiesAsync.when(
          data: (entities) => _buildEntityList(context, entities),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Refresh entities
          await ref.read(refreshEntitiesProvider)();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
  
  Widget _buildEntityList(BuildContext context, List<HAEntity> entities) {
    // Group entities by domain
    final Map<String, List<HAEntity>> groupedEntities = {};
    
    for (final entity in entities) {
      final domain = entity.entityType;
      if (!groupedEntities.containsKey(domain)) {
        groupedEntities[domain] = [];
      }
      groupedEntities[domain]!.add(entity);
    }
    
    // Sort domains
    final sortedDomains = groupedEntities.keys.toList()..sort();
    
    return ListView.builder(
      itemCount: sortedDomains.length,
      itemBuilder: (context, index) {
        final domain = sortedDomains[index];
        final domainEntities = groupedEntities[domain]!;
        
        return ExpansionTile(
          title: Text(
            domain.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: domainEntities.length,
              itemBuilder: (context, entityIndex) {
                final entity = domainEntities[entityIndex];
                return _buildEntityCard(context, entity);
              },
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildEntityCard(BuildContext context, HAEntity entity) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              entity.friendlyName,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              entity.state,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
} 