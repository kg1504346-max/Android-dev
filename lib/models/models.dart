// lib/models/models.dart

import 'package:flutter/material.dart';

// SECURITY ALERT MODEL
class SecurityAlert {
  final String id;
  final String type;
  final String location;
  final String time;
  final String severity;

  SecurityAlert({
    required this.id,
    required this.type,
    required this.location,
    required this.time,
    required this.severity,
  });
}

// CAMERA MODEL
class Camera {
  final String id;
  final String name;
  final String status;
  bool recording;

  Camera({
    required this.id,
    required this.name,
    required this.status,
    this.recording = false,
  });
}

// SENSOR MODEL
class Sensor {
  final String id;
  final String name;
  String status;
  final int battery;
  final String location;
  bool breached;

  Sensor({
    required this.id,
    required this.name,
    required this.status,
    required this.battery,
    required this.location,
    this.breached = false,
  });
}

// ARCHIVE RECORD MODEL
class ArchiveRecord {
  final String id;
  final String camera;
  final String timestamp;
  final String duration;
  final List<String> detections;
  final String thumbnail;
  final String type;

  ArchiveRecord({
    required this.id,
    required this.camera,
    required this.timestamp,
    required this.duration,
    required this.detections,
    required this.thumbnail,
    required this.type,
  });
}

// TIMELINE EVENT MODEL
class TimelineEvent {
  final String id;
  final String type; // 'motion', 'door', 'camera', 'alert', 'system'
  final String title;
  final String location;
  final DateTime timestamp;
  final String thumbnail; // Emoji or image URL
  final String description;
  final String severity; // 'critical', 'high', 'normal', 'low'

  TimelineEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.location,
    required this.timestamp,
    required this.thumbnail,
    required this.description,
    required this.severity,
  });
}

// SMART NOTIFICATION MODELS
enum NotificationPriority {
  critical, // Fire, intrusion, emergency
  high, // Motion detected, door opened
  normal, // System armed/disarmed
  low, // Battery warnings, updates
}

class SmartNotification {
  final String id;
  final String title;
  final String body;
  final String category;
  final String? location;
  final NotificationPriority priority;
  DateTime timestamp;
  final List<NotificationAction> actions;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;
  bool isGrouped;
  int groupCount;

  SmartNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.location,
    this.priority = NotificationPriority.normal,
    DateTime? timestamp,
    this.actions = const [],
    this.thumbnailUrl,
    this.metadata,
    this.isGrouped = false,
    this.groupCount = 1,
  }) : timestamp = timestamp ?? DateTime.now();

  Color get priorityColor {
    switch (priority) {
      case NotificationPriority.critical:
        return const Color(0xFFD32F2F);
      case NotificationPriority.high:
        return const Color(0xFFFF6F00);
      case NotificationPriority.normal:
        return const Color(0xFF1976D2);
      case NotificationPriority.low:
        return const Color(0xFF757575);
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'motion':
        return Icons.directions_walk;
      case 'door':
        return Icons.door_front_door;
      case 'camera':
        return Icons.videocam;
      case 'fire':
        return Icons.local_fire_department;
      case 'system':
        return Icons.security;
      default:
        return Icons.notifications;
    }
  }
}

class NotificationAction {
  final String id;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  NotificationAction({
    required this.id,
    required this.label,
    required this.icon,
    this.onTap,
  });
}

// AI ASSISTANT MODELS
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;
  final List<ActionButton>? actionButtons;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
    this.actionButtons,
  });
}

class AIResponse {
  final String text;
  final List<String>? suggestions;
  final List<ActionButton>? actionButtons;

  AIResponse({
    required this.text,
    this.suggestions,
    this.actionButtons,
  });
}

class ActionButton {
  final String label;
  final IconData icon;
  final String action;

  ActionButton({
    required this.label,
    required this.icon,
    required this.action,
  });
}
