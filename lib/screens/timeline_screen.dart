import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../models/models.dart';

class TimelineScreen extends StatefulWidget {
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Motion', 'Door', 'Camera', 'Alert', 'System'];

  // Mock timeline events (in production, this would come from your database)
  List<TimelineEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _generateMockEvents();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateMockEvents() {
    final now = DateTime.now();
    _events = [
      TimelineEvent(
        id: '1',
        type: 'alert',
        title: 'Motion Detected',
        location: 'Front Door',
        timestamp: now.subtract(Duration(minutes: 5)),
        thumbnail: '📹',
        description: 'PIR sensor triggered at main entrance',
        severity: 'high',
      ),
      TimelineEvent(
        id: '2',
        type: 'door',
        title: 'Door Opened',
        location: 'Main Entrance',
        timestamp: now.subtract(Duration(hours: 2)),
        thumbnail: '🚪',
        description: 'Authorized access - Owner',
        severity: 'normal',
      ),
      TimelineEvent(
        id: '3',
        type: 'system',
        title: 'System Armed',
        location: 'Security Panel',
        timestamp: now.subtract(Duration(hours: 8)),
        thumbnail: '🛡️',
        description: 'Night mode activated automatically',
        severity: 'normal',
      ),
      TimelineEvent(
        id: '4',
        type: 'camera',
        title: 'Recording Started',
        location: 'Living Room Camera',
        timestamp: now.subtract(Duration(hours: 10)),
        thumbnail: '🎥',
        description: 'Motion-triggered recording (2m 34s)',
        severity: 'low',
      ),
      TimelineEvent(
        id: '5',
        type: 'motion',
        title: 'Motion Detected',
        location: 'Backyard',
        timestamp: now.subtract(Duration(days: 1, hours: 3)),
        thumbnail: '🏃',
        description: 'Outdoor sensor activated',
        severity: 'low',
      ),
      TimelineEvent(
        id: '6',
        type: 'alert',
        title: 'Smoke Detected',
        location: 'Kitchen',
        timestamp: now.subtract(Duration(days: 1, hours: 12)),
        thumbnail: '💨',
        description: 'Environmental sensor alert - Resolved',
        severity: 'critical',
      ),
      TimelineEvent(
        id: '7',
        type: 'door',
        title: 'Kids Arrived Home',
        location: 'Front Door',
        timestamp: now.subtract(Duration(days: 1, hours: 15)),
        thumbnail: '👦',
        description: 'Door opened at 3:15 PM',
        severity: 'normal',
      ),
      TimelineEvent(
        id: '8',
        type: 'system',
        title: 'System Disarmed',
        location: 'Security Panel',
        timestamp: now.subtract(Duration(days: 2, hours: 1)),
        thumbnail: '🔓',
        description: 'Manual disarm by user',
        severity: 'normal',
      ),
    ];
  }

  List<TimelineEvent> get _filteredEvents {
    if (_selectedFilter == 'All') return _events;
    return _events.where((event) {
      return event.type.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              _buildFilterChips(),
              _buildStatsBar(),
              Expanded(child: _buildTimelineList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  'Activity Timeline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredEvents.length} events found',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () {
              // Show date range picker
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                HapticFeedback.selectionClick();
              },
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: Colors.white.withOpacity(0.3),
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsBar() {
    final today = _events.where((e) {
      final now = DateTime.now();
      return e.timestamp.year == now.year &&
          e.timestamp.month == now.month &&
          e.timestamp.day == now.day;
    }).length;

    final alerts = _events.where((e) => e.severity == 'high' || e.severity == 'critical').length;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Today', today.toString(), Icons.today),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
          _buildStatItem('Alerts', alerts.toString(), Icons.warning_amber),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
          _buildStatItem('Total', _events.length.toString(), Icons.list_alt),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTimelineList() {
    final filteredEvents = _filteredEvents;

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              'No events found',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        final isLast = index == filteredEvents.length - 1;

        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.1,
                (index * 0.1) + 0.3,
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.5, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index * 0.1,
                  (index * 0.1) + 0.3,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: _buildTimelineItem(event, isLast),
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(TimelineEvent event, bool isLast) {
    return Dismissible(
      key: Key(event.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _events.remove(event);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                setState(() {
                  _events.add(event);
                  _events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                });
              },
            ),
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline line with dot
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getSeverityColor(event.severity),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _getSeverityColor(event.severity).withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16),
            // Event card
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showEventDetails(event);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
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
                      color: Colors.white.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            event.thumbnail,
                            style: TextStyle(fontSize: 32),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white60,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      event.location,
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white38,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        event.description,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.white54,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatTimestamp(event.timestamp),
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(event.severity).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getSeverityColor(event.severity).withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              event.severity.toUpperCase(),
                              style: TextStyle(
                                color: _getSeverityColor(event.severity),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(TimelineEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        event.thumbnail,
                        style: TextStyle(fontSize: 64),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      event.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Text(
                          event.location,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildDetailRow('Time', _formatTimestamp(event.timestamp)),
                    _buildDetailRow('Type', event.type.toUpperCase()),
                    _buildDetailRow('Severity', event.severity.toUpperCase()),
                    _buildDetailRow('Event ID', event.id),
                    SizedBox(height: 24),
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      event.description,
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to camera view
                            },
                            icon: Icon(Icons.videocam),
                            label: Text('View Recording'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Share event
                            },
                            icon: Icon(Icons.share),
                            label: Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineEvent {
  final String id;
  final String type;
  final String title;
  final String location;
  final DateTime timestamp;
  final String thumbnail;
  final String description;
  final String severity;

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