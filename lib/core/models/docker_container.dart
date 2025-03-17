import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

part 'docker_container.g.dart';

/// Model representing a Docker container
@JsonSerializable(explicitToJson: true)
class DockerContainer {
  /// Container ID
  final String id;
  
  /// Container name
  final String name;
  
  /// Container image
  final String image;
  
  /// Container state (running, stopped, etc.)
  final String state;
  
  /// Container status
  final String status;
  
  /// Container ports mapping
  final List<PortMapping> ports;
  
  /// Created timestamp
  final String created;
  
  DockerContainer({
    required this.id,
    required this.name,
    required this.image,
    required this.state,
    required this.status,
    required this.ports,
    required this.created,
  });
  
  /// Check if the container is running
  bool get isRunning => state == 'running';
  
  /// Create from Map/JSON
  factory DockerContainer.fromJson(Map<String, dynamic> json) {
    try {
      // Handle port mapping - convert created timestamp to string if it's a number
      final createdValue = json['created'];
      final String createdString = createdValue is int 
        ? createdValue.toString() 
        : createdValue as String;
      
      // Handle ports - if it's null or not a list, provide an empty list
      List<dynamic> portsRaw = [];
      if (json['ports'] != null) {
        if (json['ports'] is List) {
          portsRaw = json['ports'] as List<dynamic>;
        } else {
          if (kDebugMode) {
            print('Warning: ports is not a list: ${json['ports'].runtimeType}');
          }
        }
      }
      
      // Convert ports to proper format
      final List<PortMapping> portsList = portsRaw.map((portJson) {
        try {
          return PortMapping.fromJson(portJson as Map<String, dynamic>);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing port mapping: $e');
            print('Port data: $portJson');
          }
          // Return a default port mapping in case of error
          return PortMapping(internal: 0, external: 0, protocol: 'unknown');
        }
      }).toList();
      
      return DockerContainer(
        id: json['id'] as String,
        name: json['name'] as String,
        image: json['image'] as String,
        state: json['state'] as String,
        status: json['status'] as String,
        ports: portsList,
        created: createdString,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating DockerContainer from JSON: $e');
        print('JSON data: $json');
      }
      // Return a placeholder container in case of error
      return DockerContainer(
        id: 'error',
        name: 'Error: ${e.toString().substring(0, math.min(50, e.toString().length))}',
        image: 'unknown',
        state: 'error',
        status: 'Error parsing data',
        ports: [],
        created: DateTime.now().toString(),
      );
    }
  }
  
  /// Convert to Map/JSON
  Map<String, dynamic> toJson() => _$DockerContainerToJson(this);
}

/// Model representing a port mapping for a container
@JsonSerializable()
class PortMapping {
  /// Internal port
  final int internal;
  
  /// External port
  final int external;
  
  /// Protocol (tcp, udp)
  final String protocol;
  
  PortMapping({
    required this.internal,
    required this.external,
    required this.protocol,
  });
  
  /// Create from Map/JSON
  factory PortMapping.fromJson(Map<String, dynamic> json) {
    try {
      return _$PortMappingFromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing PortMapping: $e');
        print('JSON data: $json');
      }
      return PortMapping(
        internal: 0,
        external: 0,
        protocol: 'error',
      );
    }
  }
  
  /// Convert to Map/JSON
  Map<String, dynamic> toJson() => _$PortMappingToJson(this);
} 