import 'package:json_annotation/json_annotation.dart';

part 'ha_entity.g.dart';

/// Model representing a Home Assistant entity
@JsonSerializable(explicitToJson: true)
class HAEntity {
  /// Entity ID in Home Assistant (e.g., 'light.living_room')
  @JsonKey(name: 'entity_id')
  final String entityId;
  
  /// Current state of the entity
  final String state;
  
  /// Entity type (e.g., 'light', 'switch', 'sensor')
  String get entityType => entityId.split('.').first;
  
  /// Entity name from the attributes or fallback to ID
  String get friendlyName => attributes['friendly_name'] as String? ?? entityId;
  
  /// Last updated timestamp
  @JsonKey(name: 'last_updated')
  final String lastUpdated;
  
  /// Last changed timestamp
  @JsonKey(name: 'last_changed')
  final String lastChanged;
  
  /// Entity attributes
  final Map<String, dynamic> attributes;
  
  /// Context information
  final Map<String, dynamic> context;

  HAEntity({
    required this.entityId,
    required this.state,
    required this.lastUpdated,
    required this.lastChanged,
    required this.attributes,
    required this.context,
  });

  /// Helper method to get icon from attributes or provide a default
  String get icon => attributes['icon'] as String? ?? _getDefaultIcon();
  
  /// Get domain-specific icon
  String _getDefaultIcon() {
    switch (entityType) {
      case 'light':
        return 'mdi:lightbulb';
      case 'switch':
        return 'mdi:toggle-switch';
      case 'sensor':
        return 'mdi:eye';
      case 'climate':
        return 'mdi:thermostat';
      case 'media_player':
        return 'mdi:play-circle';
      case 'camera':
        return 'mdi:camera';
      case 'binary_sensor':
        return 'mdi:radiobox-marked';
      default:
        return 'mdi:flash';
    }
  }
  
  /// Create from Map/JSON
  factory HAEntity.fromJson(Map<String, dynamic> json) => _$HAEntityFromJson(json);
  
  /// Convert to Map/JSON
  Map<String, dynamic> toJson() => _$HAEntityToJson(this);
} 