// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ha_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HAEntity _$HAEntityFromJson(Map<String, dynamic> json) => HAEntity(
  entityId: json['entity_id'] as String,
  state: json['state'] as String,
  lastUpdated: json['last_updated'] as String,
  lastChanged: json['last_changed'] as String,
  attributes: json['attributes'] as Map<String, dynamic>,
  context: json['context'] as Map<String, dynamic>,
);

Map<String, dynamic> _$HAEntityToJson(HAEntity instance) => <String, dynamic>{
  'entity_id': instance.entityId,
  'state': instance.state,
  'last_updated': instance.lastUpdated,
  'last_changed': instance.lastChanged,
  'attributes': instance.attributes,
  'context': instance.context,
};
