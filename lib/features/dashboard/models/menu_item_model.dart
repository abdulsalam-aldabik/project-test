import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final bool isActive;
  
  const MenuItem({
    required this.title,
    required this.icon,
    this.isActive = false,
  });
} 