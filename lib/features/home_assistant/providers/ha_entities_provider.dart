import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/models/ha_entity.dart';
import '../../../core/services/service_providers.dart';

/// Provider for all Home Assistant entities
final haEntitiesProvider = FutureProvider<List<HAEntity>>((ref) async {
  final haApiService = ref.watch(haApiServiceProvider);
  return await haApiService.fetchStates();
});

/// Provider for filtered entities by domain
final filteredEntitiesProvider = Provider.family<List<HAEntity>, String>((ref, domain) {
  final entitiesAsyncValue = ref.watch(haEntitiesProvider);
  
  return entitiesAsyncValue.when(
    data: (entities) {
      if (domain.isEmpty) return entities;
      return entities.where((entity) => entity.entityType == domain).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for a specific entity by ID
final entityByIdProvider = Provider.family<HAEntity?, String>((ref, entityId) {
  final entitiesAsyncValue = ref.watch(haEntitiesProvider);
  
  return entitiesAsyncValue.when(
    data: (entities) {
      try {
        return entities.firstWhere((entity) => entity.entityId == entityId);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Real-time provider for a specific entity by ID
/// This provider maintains its own state that can be updated immediately
final realtimeEntityProvider = StateNotifierProvider.family<EntityNotifier, AsyncValue<HAEntity?>, String>(
  (ref, entityId) => EntityNotifier(ref, entityId),
);

/// Provider for all Home Assistant entities with real-time updates
final haEntitiesRealtimeProvider = StateNotifierProvider<HAEntitiesNotifier, AsyncValue<List<HAEntity>>>((ref) {
  return HAEntitiesNotifier(ref);
});

/// Notifier for all Home Assistant entities with real-time updates
class HAEntitiesNotifier extends StateNotifier<AsyncValue<List<HAEntity>>> {
  final Ref _ref;
  StreamSubscription? _wsSubscription;
  Timer? _refreshTimer;
  
  HAEntitiesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadEntities();
    _subscribeToWebSocket();
    
    // Set up a periodic refresh as a fallback in case WebSocket fails
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadEntities();
    });
  }
  
  Future<void> _loadEntities() async {
    try {
      final haApiService = _ref.read(haApiServiceProvider);
      final entities = await haApiService.fetchStates();
      if (!mounted) return;
      state = AsyncValue.data(entities);
      
      // Print confirmation of successful refresh
      print('Successfully refreshed ${entities.length} entities');
    } catch (e) {
      if (!mounted) return;
      print('Error loading entities: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  void _subscribeToWebSocket() {
    final haApiService = _ref.read(haApiServiceProvider);
    
    // Connect to WebSocket
    haApiService.connectWebSocket().then((_) {
      // Subscribe to state changed events
      haApiService.subscribeToEvents('state_changed');
      print('HAEntitiesNotifier connected to WebSocket');
      
      // Listen to WebSocket events
      _wsSubscription = haApiService.wsEvents.listen((event) {
        if (event['type'] == 'event' && 
            event['event']?['event_type'] == 'state_changed') {
          
          // Get the updated entity
          final data = event['event']['data'];
          final newState = data['new_state'];
          final entityId = data['entity_id'];
          
          if (newState != null) {
            try {
              final updatedEntity = HAEntity.fromJson(newState);
              
              // Print confirmation of entity update
              print('Entity updated via WebSocket: ${updatedEntity.entityId}');
              
              // Update the state with the new entity
              state.whenData((entities) {
                if (!mounted) return;
                
                // Find and replace the updated entity
                final updatedEntities = entities.map((entity) {
                  if (entity.entityId == updatedEntity.entityId) {
                    return updatedEntity;
                  }
                  return entity;
                }).toList();
                
                // Update the state
                state = AsyncValue.data(updatedEntities);
              });
            } catch (e) {
              print('Error parsing entity update: $e');
            }
          }
        }
      });
    }).catchError((e) {
      print('Error connecting to WebSocket: $e');
      // If WebSocket fails, we still have the periodic refresh
    });
  }
  
  /// Force refresh all entities
  Future<void> refresh() async {
    print('Manual refresh of all entities requested');
    await _loadEntities();
  }
  
  @override
  void dispose() {
    _wsSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Notifier for real-time entity updates
class EntityNotifier extends StateNotifier<AsyncValue<HAEntity?>> {
  final Ref _ref;
  final String entityId;
  StreamSubscription? _wsSubscription;
  Timer? _refreshTimer;
  
  EntityNotifier(this._ref, this.entityId) : super(const AsyncValue.loading()) {
    _loadEntity();
    _subscribeToWebSocket();
    
    // Set up a periodic refresh as a fallback in case WebSocket fails
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadEntity();
    });
    
    // Listen to the main entities provider for background updates
    _ref.listen(haEntitiesProvider, (previous, next) {
      next.whenData((entities) {
        try {
          final entity = entities.firstWhere((e) => e.entityId == entityId);
          if (!mounted) return;
          state = AsyncValue.data(entity);
        } catch (e) {
          // Entity not found, do nothing
        }
      });
    });
  }
  
  /// Subscribe to WebSocket events for this entity
  void _subscribeToWebSocket() {
    final haApiService = _ref.read(haApiServiceProvider);
    
    // Make sure WebSocket is connected
    haApiService.connectWebSocket().then((_) {
      // Subscribe to state changed events
      haApiService.subscribeToEvents('state_changed');
      
      // Listen to WebSocket events
      _wsSubscription = haApiService.wsEvents.listen((event) {
        if (event['type'] == 'event' && 
            event['event']?['event_type'] == 'state_changed') {
          
          final data = event['event']['data'];
          final changedEntityId = data['entity_id'];
          
          // Only update if this is the entity we care about
          if (changedEntityId == entityId) {
            final newState = data['new_state'];
            if (newState != null) {
              try {
                final entity = HAEntity.fromJson(newState);
                if (mounted) {
                  state = AsyncValue.data(entity);
                }
              } catch (e) {
                print('Error parsing entity update: $e');
              }
            }
          }
        }
      });
    }).catchError((e) {
      print('Error connecting to WebSocket: $e');
    });
  }
  
  Future<void> _loadEntity() async {
    final haApiService = _ref.read(haApiServiceProvider);
    
    try {
      final entity = await haApiService.fetchEntityState(entityId);
      if (!mounted) return;
      state = AsyncValue.data(entity);
    } catch (e) {
      if (!mounted) return;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  /// Update the entity state locally (for immediate UI feedback)
  void updateState(String newState, [Map<String, dynamic>? attributes]) {
    state.whenData((entity) {
      if (entity == null) return;
      
      // Create a new entity with the updated state
      final updatedEntity = HAEntity(
        entityId: entity.entityId,
        state: newState,
        attributes: {...entity.attributes, ...?attributes},
        lastChanged: DateTime.now().toIso8601String(),
        context: entity.context,
        lastUpdated: DateTime.now().toIso8601String(),
      );
      
      state = AsyncValue.data(updatedEntity);
    });
  }
  
  /// Refresh the entity from the API
  Future<void> refresh() async {
    await _loadEntity();
  }
  
  @override
  void dispose() {
    _wsSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Provider for refreshing entities (triggers a refresh)
final refreshEntitiesProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // This will force a refresh of the entities
    ref.refresh(haEntitiesProvider);
  };
}); 