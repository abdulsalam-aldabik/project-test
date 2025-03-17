// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DockerContainer _$DockerContainerFromJson(Map<String, dynamic> json) =>
    DockerContainer(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      state: json['state'] as String,
      status: json['status'] as String,
      ports:
          (json['ports'] as List<dynamic>)
              .map((e) => PortMapping.fromJson(e as Map<String, dynamic>))
              .toList(),
      created: json['created'] as String,
    );

Map<String, dynamic> _$DockerContainerToJson(DockerContainer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'state': instance.state,
      'status': instance.status,
      'ports': instance.ports.map((e) => e.toJson()).toList(),
      'created': instance.created,
    };

PortMapping _$PortMappingFromJson(Map<String, dynamic> json) => PortMapping(
  internal: (json['internal'] as num).toInt(),
  external: (json['external'] as num).toInt(),
  protocol: json['protocol'] as String,
);

Map<String, dynamic> _$PortMappingToJson(PortMapping instance) =>
    <String, dynamic>{
      'internal': instance.internal,
      'external': instance.external,
      'protocol': instance.protocol,
    };
