import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AISecurityAssistant extends StatefulWidget {
  @override
  _AISecurityAssistantState createState() => _AISecurityAssistantState();
}

class _AISecurityAssistantState extends State<AISecurityAssistant>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();

    // Welcome message
    _addMessage(ChatMessage(
      text: "👋 Hi! I'm your AI Security Assistant. I can help you with:\n\n"
          "• Check security status\n"
          "• View recent alerts\n"
          "• Control cameras\n"
          "• Analyze activity patterns\n"
          "• Answer security questions\n\n"
          "Try asking: 'Show me alerts from yesterday' or 'Was anyone at the door today?'",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _addMessage(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _messageController.clear();

    // Show typing indicator
    setState(() => _isTyping = true);

    // Simulate AI processing delay
    await Future.delayed(Duration(seconds: 2));

    // Generate AI response
    final response = _generateAIResponse(text);

    setState(() => _isTyping = false);

    _addMessage(ChatMessage(
      text: response.text,
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: response.suggestions,
      actionButtons: response.actionButtons,
    ));
  }

  AIResponse _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Status check queries
    if (lowerMessage.contains('status') ||
        lowerMessage.contains('how is') ||
        lowerMessage.contains('everything ok')) {
      return AIResponse(
        text: "🛡️ **System Status: All Clear**\n\n"
            "✅ All sensors active (8/8)\n"
            "✅ Cameras recording (4/4)\n"
            "✅ System armed since 10:30 PM\n"
            "✅ No alerts in last 24 hours\n\n"
            "Your home is secure! 🏠",
        suggestions: [
          'Show me camera feeds',
          'View sensor details',
          'Check battery levels'
        ],
      );
    }

    // Alert history queries
    if (lowerMessage.contains('alert') ||
        lowerMessage.contains('yesterday') ||
        lowerMessage.contains('recent')) {
      return AIResponse(
        text: "📋 **Recent Alerts Summary**\n\n"
            "🕐 **Today**\n"
            "• 2:45 PM - Motion detected at Front Door\n"
            "• 8:30 AM - Door opened (Main Entrance)\n\n"
            "🕐 **Yesterday**\n"
            "• 6:15 PM - Motion in Backyard\n"
            "• 3:30 PM - Kids arrived home\n"
            "• 11:45 AM - Package delivery detected\n\n"
            "Total: 5 events in last 48 hours",
        suggestions: [
          'Show video recordings',
          'Filter by camera',
          'Export report'
        ],
        actionButtons: [
          ActionButton(
            label: 'View Timeline',
            icon: Icons.timeline,
            action: 'view_timeline',
          ),
          ActionButton(
            label: 'Watch Videos',
            icon: Icons.play_circle,
            action: 'watch_videos',
          ),
        ],
      );
    }

    // Door activity queries
    if (lowerMessage.contains('door') ||
        lowerMessage.contains('who came') ||
        lowerMessage.contains('entry')) {
      return AIResponse(
        text: "🚪 **Door Activity Today**\n\n"
            "✅ **8:30 AM** - Main entrance opened\n"
            "   • Identified: Owner (via key fob)\n"
            "   • Duration: Door open for 12 seconds\n\n"
            "✅ **3:15 PM** - Front door opened\n"
            "   • Identified: Family member\n"
            "   • Camera captured entry\n\n"
            "No unauthorized access detected! 🔒",
        suggestions: [
          'Show door camera footage',
          'Who has access?',
          'Lock all doors now'
        ],
      );
    }

    // Motion detection queries
    if (lowerMessage.contains('motion') ||
        lowerMessage.contains('movement') ||
        lowerMessage.contains('someone')) {
      return AIResponse(
        text: "🚶 **Motion Detection Analysis**\n\n"
            "📊 **Last 24 Hours:**\n"
            "• Front Door: 8 events\n"
            "• Backyard: 3 events\n"
            "• Living Room: 12 events\n"
            "• Garage: 2 events\n\n"
            "🎯 **Pattern Analysis:**\n"
            "Most activity between 3 PM - 6 PM (typical arrival times)\n"
            "No unusual patterns detected",
        suggestions: [
          'Show motion clips',
          'Adjust sensitivity',
          'Set custom zones'
        ],
      );
    }

    // Camera queries
    if (lowerMessage.contains('camera') ||
        lowerMessage.contains('video') ||
        lowerMessage.contains('recording')) {
      return AIResponse(
        text: "📹 **Camera System Status**\n\n"
            "✅ Front Door Camera - Active\n"
            "   • Recording: Yes\n"
            "   • Storage: 45% used\n\n"
            "✅ Backyard Camera - Active\n"
            "   • Recording: Yes\n"
            "   • Last motion: 2 hours ago\n\n"
            "✅ Living Room Camera - Active\n"
            "   • Recording: Scheduled\n"
            "   • Quality: 1080p HD\n\n"
            "✅ Garage Camera - Active\n"
            "   • Recording: Yes\n"
            "   • Night vision: Enabled",
        suggestions: [
          'View live feeds',
          'Manage storage',
          'Download clips'
        ],
        actionButtons: [
          ActionButton(
            label: 'Live View',
            icon: Icons.videocam,
            action: 'live_view',
          ),
        ],
      );
    }

    // Family activity queries
    if (lowerMessage.contains('kids') ||
        lowerMessage.contains('family') ||
        lowerMessage.contains('arrived') ||
        lowerMessage.contains('home')) {
      return AIResponse(
        text: "👨‍👩‍👧‍👦 **Family Activity Dashboard**\n\n"
            "🏫 **Kids arrived home:**\n"
            "   • 3:15 PM today\n"
            "   • Front door entry detected\n"
            "   • Safe arrival confirmed ✅\n\n"
            "🚗 **Last garage activity:**\n"
            "   • 8:30 AM - Garage opened\n"
            "   • Car departed for work\n\n"
            "📱 **Family members at home:**\n"
            "   • 2 people currently inside\n"
            "   • Last check: 5 minutes ago",
        suggestions: [
          'Set arrival notifications',
          'View departure times',
          'Family calendar'
        ],
      );
    }

    // Arming/disarming queries
    if (lowerMessage.contains('arm') ||
        lowerMessage.contains('disarm') ||
        lowerMessage.contains('lock') ||
        lowerMessage.contains('unlock')) {
      return AIResponse(
        text: "🔐 **Security Control**\n\n"
            "Current state: System ARMED\n"
            "Mode: AWAY (Night mode)\n"
            "All doors: LOCKED 🔒\n\n"
            "Would you like to change the security state?",
        suggestions: [
          'Disarm system',
          'Lock all doors',
          'Enable guest mode'
        ],
        actionButtons: [
          ActionButton(
            label: 'Disarm',
            icon: Icons.lock_open,
            action: 'disarm',
          ),
          ActionButton(
            label: 'Arm Away',
            icon: Icons.shield,
            action: 'arm_away',
          ),
        ],
      );
    }

    // Battery/maintenance queries
    if (lowerMessage.contains('battery') ||
        lowerMessage.contains('maintenance') ||
        lowerMessage.contains('check sensors')) {
      return AIResponse(
        text: "🔋 **Sensor Health Report**\n\n"
            "✅ Front Door Sensor: 85% battery\n"
            "✅ Back Door Sensor: 92% battery\n"
            "✅ Living Room Motion: 78% battery\n"
            "⚠️ Garage Sensor: 23% battery (replace soon)\n"
            "✅ Smoke Detector: 88% battery\n\n"
            "💡 Tip: Replace batteries annually for best performance",
        suggestions: [
          'Order replacement batteries',
          'Schedule maintenance',
          'Sensor diagnostics'
        ],
      );
    }

    // Help/capabilities queries
    if (lowerMessage.contains('help') ||
        lowerMessage.contains('what can you') ||
        lowerMessage.contains('capabilities')) {
      return AIResponse(
        text: "🤖 **AI Assistant Capabilities**\n\n"
            "I can help you with:\n\n"
            "📊 **Monitoring:**\n"
            "• Check system status\n"
            "• View recent alerts\n"
            "• Analyze activity patterns\n\n"
            "🎥 **Cameras:**\n"
            "• View live feeds\n"
            "• Access recordings\n"
            "• Manage storage\n\n"
            "🔐 **Control:**\n"
            "• Arm/disarm system\n"
            "• Lock/unlock doors\n"
            "• Adjust settings\n\n"
            "📱 **Insights:**\n"
            "• Family activity tracking\n"
            "• Security reports\n"
            "• Smart suggestions",
        suggestions: [
          'Show me recent alerts',
          'Check system status',
          'View camera feeds'
        ],
      );
    }

    // Default response for unrecognized queries
    return AIResponse(
      text: "🤔 I'm not sure I understand that request.\n\n"
          "I can help you with:\n"
          "• Security system status\n"
          "• Recent alerts and events\n"
          "• Camera and sensor information\n"
          "• Family activity tracking\n"
          "• System control commands\n\n"
          "Try asking something like:\n"
          "'Show me alerts from yesterday' or\n"
          "'Was anyone at the door today?'",
      suggestions: [
        'Check system status',
        'Show recent alerts',
        'View cameras'
      ],
    );
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
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.blue],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.smart_toy, color: Colors.white, size: 28),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Security Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showAssistantSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
                ),
                SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[900]!],
                    )
                        : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: message.isUser
                          ? Colors.blue.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      if (message.actionButtons != null &&
                          message.actionButtons!.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: message.actionButtons!.map((button) {
                            return ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                // Handle action
                              },
                              icon: Icon(button.icon, size: 16),
                              label: Text(button.label),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                textStyle: TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (message.isUser) ...[
                SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ],
            ],
          ),
          if (message.suggestions != null && message.suggestions!.isNotEmpty) ...[
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.suggestions!.map((suggestion) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _sendMessage(suggestion);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white70,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          suggestion,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.blue],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4),
                _buildTypingDot(1),
                SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final value = (_typingAnimationController.value + delay) % 1.0;
        final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2);

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3 + opacity * 0.7),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.mic, color: Colors.white70),
                    onPressed: () {
                      // Voice input
                      HapticFeedback.mediumImpact();
                    },
                  ),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                HapticFeedback.mediumImpact();
                _sendMessage(_messageController.text);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showAssistantSettings() {
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
            Text(
              'Assistant Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            _buildSettingsTile(
              'Voice Response',
              'Enable voice feedback',
              Icons.volume_up,
              true,
            ),
            _buildSettingsTile(
              'Smart Suggestions',
              'Show quick action suggestions',
              Icons.lightbulb,
              true,
            ),
            _buildSettingsTile(
              'Learning Mode',
              'Improve responses based on usage',
              Icons.psychology,
              true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _messages.clear();
                });
                Navigator.pop(context);
              },
              child: Text('Clear Conversation History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.3),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {},
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

// Chat message model
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

// AI Response model
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

// Action button model
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