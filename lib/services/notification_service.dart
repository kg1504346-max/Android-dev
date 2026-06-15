import 'package:flutter/services.dart';
import 'dart:async';
import '../models/models.dart';
import 'package:flutter/material.dart';
import 'sms_service.dart'; // ✅ Added import

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final SmartNotificationManager _smartManager = SmartNotificationManager();

  Future<void> initialize() async {
    print('✅ Notification Service Ready');
  }

  Future<void> showBreachNotification(String location, String sensorName) async {
    try {
      // Triple vibration pattern
      await HapticFeedback.heavyImpact();
      await Future.delayed(Duration(milliseconds: 200));
      await HapticFeedback.heavyImpact();
      await Future.delayed(Duration(milliseconds: 200));
      await HapticFeedback.heavyImpact();

      // System alert sound
      await SystemSound.play(SystemSoundType.alert);

      print('🚨 SECURITY BREACH DETECTED');
      print('   Sensor: $sensorName');
      print('   Location: $location');
      print('   Alert: Vibration + Sound triggered');

      // ✅ Local SMS alert (offline, no Firebase/Twilio)
      const String alertPhoneNumber = '7892458396'; // replace with your number
      final String smsMessage =
          '🚨 ALERT: Breach detected at $location by $sensorName. Please check immediately.';
      final bool smsSent =
      await SmsService.sendSms(alertPhoneNumber, smsMessage);
      if (smsSent) {
        print('📩 SMS alert sent to $alertPhoneNumber');
      } else {
        print('⚠️ SMS alert not sent (permission or error)');
      }

      // Smart notification (unchanged)
      _smartManager.sendNotification(SmartNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Security Breach!',
        body: '$sensorName triggered at $location',
        category: 'breach',
        location: location,
        priority: NotificationPriority.critical,
        actions: [
          NotificationAction(
            id: 'view_camera',
            label: 'View Camera',
            icon: Icons.videocam,
          ),
          NotificationAction(
            id: 'call_police',
            label: 'Call Police',
            icon: Icons.phone,
          ),
        ],
      ));
    } catch (e) {
      print('Error showing breach notification: $e');
    }
  }

  SmartNotificationManager get smartManager => _smartManager;
}

// Remaining SmartNotificationManager code unchanged ↓
class SmartNotificationManager {
  static final SmartNotificationManager _instance =
  SmartNotificationManager._internal();
  factory SmartNotificationManager() => _instance;
  SmartNotificationManager._internal();

  List<SmartNotification> _notifications = [];
  List<SmartNotification> _pendingNotifications = [];
  final StreamController<SmartNotification> _notificationStream =
  StreamController.broadcast();

  bool _isUserInMeeting = false;
  bool _isDndEnabled = false;
  TimeOfDay _quietHoursStart = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = TimeOfDay(hour: 7, minute: 0);

  Stream<SmartNotification> get notificationStream => _notificationStream.stream;
  List<SmartNotification> get notifications => _notifications;
  bool get isDndEnabled => _isDndEnabled;
  bool get isUserInMeeting => _isUserInMeeting;

  Future<void> sendNotification(SmartNotification notification) async {
    if (_shouldDefer(notification)) {
      _pendingNotifications.add(notification);
      print('📴 Notification deferred: ${notification.title}');
      return;
    }

    if (_shouldGroup(notification)) {
      _groupNotification(notification);
      return;
    }

    _notifications.insert(0, notification);
    _notificationStream.add(notification);
    print('🔔 Notification sent: ${notification.title}');

    if (notification.priority == NotificationPriority.low) {
      Timer(Duration(hours: 1), () {
        _notifications.remove(notification);
      });
    }
  }

  bool _shouldDefer(SmartNotification notification) {
    if (notification.priority == NotificationPriority.critical) return false;
    if (_isDndEnabled || _isUserInMeeting) {
      return notification.priority != NotificationPriority.high;
    }
    if (_isQuietHours()) return notification.priority == NotificationPriority.low;
    return false;
  }

  bool _isQuietHours() {
    final now = TimeOfDay.now();
    final nowM = now.hour * 60 + now.minute;
    final startM = _quietHoursStart.hour * 60 + _quietHoursStart.minute;
    final endM = _quietHoursEnd.hour * 60 + _quietHoursEnd.minute;
    return startM < endM
        ? nowM >= startM && nowM <= endM
        : nowM >= startM || nowM <= endM;
  }

  bool _shouldGroup(SmartNotification notification) {
    final recent = _notifications.where((n) {
      final diff = DateTime.now().difference(n.timestamp).inMinutes;
      return diff < 10 &&
          n.category == notification.category &&
          n.location == notification.location;
    }).length;
    return recent >= 2;
  }

  void _groupNotification(SmartNotification notification) {
    final existing = _notifications.firstWhere(
          (n) =>
      n.isGrouped &&
          n.category == notification.category &&
          n.location == notification.location,
      orElse: () => _createGroupedNotification(notification),
    );
    if (existing.id != notification.id) {
      existing.groupCount++;
      existing.timestamp = DateTime.now();
      _notificationStream.add(existing);
    }
  }

  SmartNotification _createGroupedNotification(
      SmartNotification notification) {
    final grouped = SmartNotification(
      id:
      'group_${notification.category}_${DateTime.now().millisecondsSinceEpoch}',
      title: '${notification.category} Activity',
      body: 'Multiple events detected at ${notification.location}',
      category: notification.category,
      location: notification.location,
      priority: notification.priority,
      isGrouped: true,
      groupCount: 1,
      actions: [
        NotificationAction(
          id: 'view_all',
          label: 'View All',
          icon: Icons.list,
        ),
      ],
    );
    _notifications.insert(0, grouped);
    return grouped;
  }

  void clearNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
  }

  void clearAll() => _notifications.clear();

  void setDndMode(bool enabled) {
    _isDndEnabled = enabled;
    if (!enabled) _deliverPendingNotifications();
  }

  void setMeetingMode(bool inMeeting) {
    _isUserInMeeting = inMeeting;
    if (!inMeeting) _deliverPendingNotifications();
  }

  void _deliverPendingNotifications() {
    for (var n in _pendingNotifications) {
      sendNotification(n);
    }
    _pendingNotifications.clear();
  }
}
