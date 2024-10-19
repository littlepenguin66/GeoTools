import 'package:flutter/material.dart';

class Tool {
  final String name;
  final IconData icon;

  Tool({
    required this.name,
    required this.icon,
  });
}

class ToolFeature {
  final String name;
  final String description;

  ToolFeature({
    required this.name,
    required this.description,
  });
}
