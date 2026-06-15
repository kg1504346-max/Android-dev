import 'package:flutter/material.dart';
import 'dart:async';

// Smart Notification Manager with Context-Aware Intelligence
class SmartNotificationManager {
  static final SmartNotificationManager _instance = SmartNotificationManager._internal();
  factory SmartNotificationManager() => _instance;
  SmartNotificationManager._internal();

  List<SmartNotification> _notifications = [];
  List<SmartNotification> _pendingNotifications = [];
  final StreamController<SmartNotification> _notificationStream = StreamController.broadcast();

  // Context awareness
  bool _isUserInMeeting = false;
  bool _isDndEnabled = false;
  TimeOfDay _quietHoursStart = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = TimeOfDay(hour: 7, minute: 0);

  Stream<SmartNotification> get notificationStream => _notificationStream.stream;
  List<SmartNotification> get notifications => _notifications;

  // Send notification with intelligent routing
  Future<void> sendNotification(SmartNotification notification) async {
    // Check context and decide whether to deliver now or defer
    if (_shouldDefer(notification)) {
      _pendingNotifications.add(notification);
      print('📴 Notification deferred: ${notification.title}');
      return;
    }

    // Group similar notifications
    if (_shouldGroup(notification)) {
      _groupNotification(notification);
      return;
    }

    // Deliver notification
    _notifications.insert(0, notification);
    _notificationStream.add(notification);
    print('🔔 Notification sent: ${notification.title}');

    // Auto-expire low priority notifications
    if (notification.priority == NotificationPriority.low) {
      Timer(Duration(hours: 1), () {
        _notifications.remove(notification);
      });
    }
  }

  bool _shouldDefer(SmartNotification notification) {
    // Never defer critical notifications
    if (notification.priority == NotificationPriority.critical) {
      return false;
    }

    // Defer during DND or meetings
    if (_isDndEnabled || _isUserInMeeting) {
      return notification.priority != NotificationPriority.high;
    }

    // Check quiet hours
    if (_isQuietHours()) {
      return notification.priority == NotificationPriority.low;
    }

    return false;
  }

  bool _isQuietHours() {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = _quietHoursStart.hour * 60 + _quietHoursStart.minute;
    final endMinutes = _quietHoursEnd.hour * 60 + _quietHoursEnd.minute;

    if (startMinutes < endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
  }

  bool _shouldGroup(SmartNotification notification) {
    // Group similar notifications from last 10 minutes
    final recentSimilar = _notifications.where((n) {
      final timeDiff = DateTime.now().difference(n.timestamp).inMinutes;
      return timeDiff < 10 &&
          n.category == notification.category &&
          n.location == notification.location;
    }).length;

    return recentSimilar >= 2; // Group if 2+ similar notifications
  }

  void _groupNotification(SmartNotification notification) {
    // Find existing grouped notification
    final existingGroup = _notifications.firstWhere(
          (n) => n.isGrouped &&
          n.category == notification.category &&
          n.location == notification.location,
      orElse: () => _createGroupedNotification(notification),
    );

    if (existingGroup.id != notification.id) {
      existingGroup.groupCount++;
      existingGroup.timestamp = DateTime.now();
      _notificationStream.add(existingGroup);
    }
  }

  SmartNotification _createGroupedNotification(SmartNotification notification) {
    final grouped = SmartNotification(
      id: 'group_${notification.category}_${DateTime.now().millisecondsSinceEpoch}',
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

  void clearAll() {
    _notifications.clear();
  }

  void setDndMode(bool enabled) {
    _isDndEnabled = enabled;
    if (!enabled) {
      _deliverPendingNotifications();
    }
  }

  void setMeetingMode(bool inMeeting) {
    _isUserInMeeting = inMeeting;
    if (!inMeeting) {
      _deliverPendingNotifications();
    }
  }

  void _deliverPendingNotifications() {
    for (var notification in _pendingNotifications) {
      sendNotification(notification);
    }
    _pendingNotifications.clear();
  }
}

// Notification Priority Levels
enum NotificationPriority {
  critical,  // Fire, intrusion, emergency
  high,      // Motion detected, door opened
  normal,    // System armed/disarmed
  low,       // Battery warnings, updates
}

// Smart Notification Model
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
        return Colors.red;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.low:
        return Colors.grey;
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

// Smart Notification UI Screen
class SmartNotificationsScreen extends StatefulWidget {
  @override
  _SmartNotificationsScreenState createState() => _SmartNotificationsScreenState();
}

class _SmartNotificationsScreenState extends State<SmartNotificationsScreen> {
  final SmartNotificationManager _manager = SmartNotificationManager();
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _manager.notificationStream.listen((notification) {
      setState(() {});
    });
    _generateSampleNotifications();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _generateSampleNotifications() {
    // Sample notifications
    _manager.sendNotification(SmartNotification(
      id: '1',
      title: 'Motion Detected',
      body: 'Movement detected at front door',
      category: 'motion',
      location: 'Front Door',
      priority: NotificationPriority.high,
      actions: [
        NotificationAction(
          id: 'view_camera',
          label: 'View Camera',
          icon: Icons.videocam,
        ),
        NotificationAction(
          id: 'dismiss',
          label: 'Dismiss',
          icon: Icons.close,
        ),
      ],
    ));

    _manager.sendNotification(SmartNotification(
      id: '2',
      title: 'Door Opened',
      body: 'Main entrance door was opened',
      category: 'door',
      location: 'Main Entrance',
      priority: NotificationPriority.high,
      timestamp: DateTime.now().subtract(Duration(minutes: 15)),
    ));

    _manager.sendNotification(SmartNotification(
      id: '3',
      title: 'System Armed',
      body: 'Security system is now armed',
      category: 'system',
      priority: NotificationPriority.normal,
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
    ));

    _manager.sendNotification(SmartNotification(
      id: '4',
      title: 'Low Battery',
      body: 'Living room sensor battery at 15%',
      category: 'system',
      location: 'Living Room',
      priority: NotificationPriority.low,
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
    ));
  }

  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _manager.notifications;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(notifications.length),
              _buildControls(),
              Expanded(
                child: notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(notifications),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count unread messages',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          if (count > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _manager.clearAll();
                });
              },
              child: Text(
                'Clear All',
                style: TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.do_not_disturb, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Do Not Disturb',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Switch(
                value: _manager._isDndEnabled,
                onChanged: (value) {
                  setState(() {
                    _manager.setDndMode(value);
                  });
                },
                activeColor: Colors.white,
              ),
            ],
          ),
          Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.meeting_room, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Meeting Mode',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Switch(
                value: _manager._isUserInMeeting,
                onChanged: (value) {
                  setState(() {
                    _manager.setMeetingMode(value);
                  });
                },
                activeColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.white38,
          ),
          SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<SmartNotification> notifications) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Dismissible(
          key: Key(notification.id),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.check, color: Colors.white),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            setState(() {
              _manager.clearNotification(notification.id);
            });
          },
          child: _buildNotificationCard(notification),
        );
      },
    );
  }

  Widget _buildNotificationCard(SmartNotification notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.priorityColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: notification.priorityColor.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showNotificationDetails(notification);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: notification.priorityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        notification.categoryIcon,
                        color: notification.priorityColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (notification.isGrouped)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${notification.groupCount}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            _getTimeAgo(notification.timestamp),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  notification.body,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (notification.location != null) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white54,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        notification.location!,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
                if (notification.actions.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Row(
                    children: notification.actions.map((action) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ElevatedButton.icon(
                          onPressed: action.onTap ?? () {},
                          icon: Icon(action.icon, size: 16),
                          label: Text(action.label),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetails(SmartNotification notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 24),
            Icon(
              notification.categoryIcon,
              size: 64,
              color: notification.priorityColor,
            ),
            SizedBox(height: 16),
            Text(
              notification.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              notification.body,
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _manager.clearNotification(notification.id);
                  },
                  icon: Icon(Icons.check),
                  label: Text('Mark Read'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.visibility),
                  label: Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}