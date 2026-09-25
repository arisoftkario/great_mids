import 'package:flutter/material.dart';

class DepartmentOffering {
  final IconData icon;
  final String title;
  final String description;

  const DepartmentOffering({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class BusinessActivity {
  final String id;
  final String title;
  final String description;
  final String? imageAsset;
  final IconData fallbackIcon;
  final String actionLabel;
  final String requestMessage;
  final List<DepartmentOffering> offerings;

  const BusinessActivity({
    required this.id,
    required this.title,
    required this.description,
    this.imageAsset,
    required this.fallbackIcon,
    required this.actionLabel,
    required this.requestMessage,
    required this.offerings,
  });
}
