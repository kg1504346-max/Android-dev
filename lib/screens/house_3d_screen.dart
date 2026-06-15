import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/security_provider.dart';
import 'simulation_center_screen.dart';

class House3DScreen extends StatefulWidget {
  @override
  _House3DScreenState createState() => _House3DScreenState();
}

class _House3DScreenState extends State<House3DScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _glowController;
  String _selectedFloor = 'Ground Floor';
  String _selectedRoom = 'All Rooms';
  double _rotationAngle = 0.0;
  bool _autoRotate = true;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2D3561),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildControlPanel(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _build3DVisualization(),
                      SizedBox(height: 20),
                      _buildRoomGrid(),
                      SizedBox(height: 20),
                      _buildSimulationButton(),
                    ],
                  ),
                ),
              ),
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
                  '3D House Visualization',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Interactive Security Layout',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00F260), Color(0xFF0575E6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00F260).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.visibility, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('3D View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedFloor,
                  dropdownColor: Color(0xFF1A1F3A),
                  style: TextStyle(color: Colors.white),
                  underline: Container(height: 1, color: Colors.cyan),
                  isExpanded: true,
                  items: ['Ground Floor', 'First Floor', 'Basement']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFloor = newValue!;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedRoom,
                  dropdownColor: Color(0xFF1A1F3A),
                  style: TextStyle(color: Colors.white),
                  underline: Container(height: 1, color: Colors.cyan),
                  isExpanded: true,
                  items: ['All Rooms', 'Living Room', 'Kitchen', 'Bedroom', 'Garage']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRoom = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _autoRotate = !_autoRotate;
                      if (_autoRotate) {
                        _rotationController.repeat();
                      } else {
                        _rotationController.stop();
                      }
                    });
                  },
                  icon: Icon(_autoRotate ? Icons.pause : Icons.play_arrow, size: 18),
                  label: Text(_autoRotate ? 'Pause' : 'Rotate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.withOpacity(0.3),
                    foregroundColor: Colors.cyan,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _rotationAngle = 0.0;
                    });
                  },
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Reset View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.withOpacity(0.3),
                    foregroundColor: Colors.purple[200],
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build3DVisualization() {
    return Consumer<SecurityProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 380,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color(0xFF1A1F3A),
                Color(0xFF0A0E27),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.cyan.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Animated grid background
                CustomPaint(
                  size: Size.infinite,
                  painter: GridBackgroundPainter(),
                ),

                // Main 3D House
                Center(
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(double.infinity, 380),
                        painter: Enhanced3DHousePainter(
                          rotation: _autoRotate ? _rotationController.value : _rotationAngle,
                          breachedSensors: provider.sensors.where((s) => s.breached).toList(),
                          cameras: provider.cameras,
                          glowAnimation: _glowController.value,
                        ),
                      );
                    },
                  ),
                ),

                // Legend with glassmorphism
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Legend',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildLegendItem(Color(0xFF00F260), 'Active Sensors'),
                        _buildLegendItem(Colors.red, 'Breached'),
                        _buildLegendItem(Color(0xFF0575E6), 'Cameras Online'),
                        _buildLegendItem(Colors.orange, 'Motion Detected'),
                      ],
                    ),
                  ),
                ),

                // Status indicator
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      final hasBreaches = provider.sensors.any((s) => s.breached);
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: hasBreaches
                                ? [Colors.red, Colors.red[700]!]
                                : [Color(0xFF00F260), Color(0xFF0575E6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (hasBreaches ? Colors.red : Color(0xFF00F260))
                                  .withOpacity(_glowController.value * 0.6),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasBreaches ? Icons.warning : Icons.security,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              hasBreaches ? 'BREACH DETECTED' : 'System Secure',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomGrid() {
    return Consumer<SecurityProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Security Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildRoomCard('Front Door', Icons.door_front_door,
                    provider.sensors.where((s) => s.location == 'Front Door').toList()),
                _buildRoomCard('Living Room', Icons.weekend,
                    provider.sensors.where((s) => s.location == 'Living Room').toList()),
                _buildRoomCard('Kitchen', Icons.kitchen,
                    provider.sensors.where((s) => s.location == 'Kitchen').toList()),
                _buildRoomCard('Bedroom', Icons.bed,
                    provider.sensors.where((s) => s.location.contains('Bedroom')).toList()),
                _buildRoomCard('Garage', Icons.garage,
                    provider.sensors.where((s) => s.location == 'Garage').toList()),
                _buildRoomCard('Basement', Icons.stairs,
                    provider.sensors.where((s) => s.location == 'Basement').toList()),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoomCard(String room, IconData icon, List sensors) {
    final hasBreachedSensor = sensors.any((s) => s.breached);
    final activeSensors = sensors.where((s) => s.status == 'active' && !s.breached).length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasBreachedSensor
              ? [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.1)]
              : [Colors.cyan.withOpacity(0.2), Colors.blue.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasBreachedSensor ? Colors.red : Colors.cyan.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasBreachedSensor ? Colors.red : Colors.cyan).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: hasBreachedSensor ? Colors.red : Colors.cyan, size: 32),
          SizedBox(height: 8),
          Text(
            room,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          if (hasBreachedSensor)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'BREACH',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            )
          else
            Text(
              '$activeSensors Active',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildSimulationButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF6B6B).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdvancedSimulationCenter()),
          );
        },
        icon: Icon(Icons.science, size: 24),
        label: Text(
          'Open Advanced Simulation Center',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.1)
      ..strokeWidth = 1;

    final spacing = 30.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(GridBackgroundPainter oldDelegate) => false;
}

class Enhanced3DHousePainter extends CustomPainter {
  final double rotation;
  final List breachedSensors;
  final List cameras;
  final double glowAnimation;

  Enhanced3DHousePainter({
    required this.rotation,
    required this.breachedSensors,
    required this.cameras,
    required this.glowAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final rotationAngle = rotation * 2 * math.pi;

    // Draw glowing base if breached
    if (breachedSensors.isNotEmpty) {
      final glowPaint = Paint()
        ..color = Colors.red.withOpacity(0.3 * glowAnimation)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30);
      canvas.drawCircle(Offset(centerX, centerY + 20), 150, glowPaint);
    }

    // Draw house foundation with gradient
    _drawFoundation(canvas, centerX, centerY, rotationAngle);

    // Draw walls
    _drawWalls(canvas, centerX, centerY, rotationAngle);

    // Draw roof with modern design
    _drawRoof(canvas, centerX, centerY, rotationAngle);

    // Draw windows
    _drawWindows(canvas, centerX, centerY, rotationAngle);

    // Draw door
    _drawDoor(canvas, centerX, centerY, rotationAngle);

    // Draw sensor points with glow
    _drawSensors(canvas, centerX, centerY, rotationAngle);

    // Draw camera positions
    _drawCameras(canvas, centerX, centerY, rotationAngle);

    // Draw breach warnings
    if (breachedSensors.isNotEmpty) {
      _drawBreachWarnings(canvas, centerX, centerY);
    }
  }

  void _drawFoundation(Canvas canvas, double centerX, double centerY, double angle) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
      ).createShader(Rect.fromLTWH(centerX - 120, centerY + 40, 240, 80));

    final path = Path();
    path.moveTo(centerX - 120, centerY + 80);
    path.lineTo(centerX - 100, centerY + 120);
    path.lineTo(centerX + 100, centerY + 120);
    path.lineTo(centerX + 120, centerY + 80);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawWalls(Canvas canvas, double centerX, double centerY, double angle) {
    // Front wall
    final frontWallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
      ).createShader(Rect.fromLTWH(centerX - 100, centerY - 40, 200, 120));

    canvas.drawRect(
      Rect.fromLTWH(centerX - 100, centerY - 40, 200, 120),
      frontWallPaint,
    );

    // Side wall with depth
    final sideWallPaint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFF2980B9), Color(0xFF1F618D)],
      ).createShader(Rect.fromLTWH(centerX + 100, centerY - 40, 60, 120));

    final sidePath = Path();
    sidePath.moveTo(centerX + 100, centerY - 40);
    sidePath.lineTo(centerX + 160, centerY - 20);
    sidePath.lineTo(centerX + 160, centerY + 100);
    sidePath.lineTo(centerX + 100, centerY + 80);
    sidePath.close();
    canvas.drawPath(sidePath, sideWallPaint);

    // Add wall outlines with glow
    final outlinePaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawRect(
      Rect.fromLTWH(centerX - 100, centerY - 40, 200, 120),
      outlinePaint,
    );
  }

  void _drawRoof(Canvas canvas, double centerX, double centerY, double angle) {
    final roofPaint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
      ).createShader(Rect.fromLTWH(centerX - 130, centerY - 100, 260, 60));

    final roofPath = Path();
    roofPath.moveTo(centerX - 130, centerY - 40);
    roofPath.lineTo(centerX, centerY - 100);
    roofPath.lineTo(centerX + 170, centerY - 20);
    roofPath.lineTo(centerX + 130, centerY - 40);
    roofPath.close();

    canvas.drawPath(roofPath, roofPaint);

    // Roof outline with glow
    final roofOutline = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(roofPath, roofOutline);

    // Chimney
    final chimneyPaint = Paint()
      ..color = Color(0xFF7F8C8D);
    canvas.drawRect(
      Rect.fromLTWH(centerX + 40, centerY - 85, 20, 35),
      chimneyPaint,
    );
  }

  void _drawWindows(Canvas canvas, double centerX, double centerY, double angle) {
    final windowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Color(0xFFFFEB3B), Color(0xFFFFC107)],
      ).createShader(Rect.fromLTWH(0, 0, 30, 30));

    // Left window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 70, centerY, 30, 35),
        Radius.circular(4),
      ),
      windowPaint,
    );

    // Right window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + 40, centerY, 30, 35),
        Radius.circular(4),
      ),
      windowPaint,
    );

    // Window glow
    final glowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(Offset(centerX - 55, centerY + 17), 20, glowPaint);
    canvas.drawCircle(Offset(centerX + 55, centerY + 17), 20, glowPaint);
  }

  void _drawDoor(Canvas canvas, double centerX, double centerY, double angle) {
    final doorBreach = breachedSensors.any((s) =>
    s.location.toString().contains('Door') ||
        s.location.toString().contains('Front'));

    final doorPaint = Paint()
      ..color = doorBreach ? Colors.red : Color(0xFF8B4513);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 15, centerY + 30, 30, 50),
        Radius.circular(6),
      ),
      doorPaint,
    );

    // Door handle
    final handlePaint = Paint()
      ..color = Colors.amber;
    canvas.drawCircle(Offset(centerX + 5, centerY + 55), 3, handlePaint);

    if (doorBreach) {
      final alertPaint = Paint()
        ..color = Colors.red.withOpacity(glowAnimation)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(Offset(centerX, centerY + 55), 40, alertPaint);
    }
  }

  void _drawSensors(Canvas canvas, double centerX, double centerY, double angle) {
    final sensorPositions = [
      Offset(centerX - 80, centerY + 10),  // Left window
      Offset(centerX + 50, centerY + 10),  // Right window
      Offset(centerX, centerY + 20),        // Door
      Offset(centerX - 40, centerY - 20),  // Upper left
      Offset(centerX + 40, centerY - 20),  // Upper right
    ];

    for (int i = 0; i < sensorPositions.length; i++) {
      final breached = i < breachedSensors.length;
      _drawSensorPoint(canvas, sensorPositions[i].dx, sensorPositions[i].dy, breached);
    }
  }

  void _drawSensorPoint(Canvas canvas, double x, double y, bool breached) {
    final paint = Paint()
      ..color = breached ? Colors.red : Color(0xFF00F260)
      ..style = PaintingStyle.fill;

    // Outer glow
    final glowPaint = Paint()
      ..color = (breached ? Colors.red : Color(0xFF00F260)).withOpacity(0.5 * glowAnimation)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, breached ? 15 : 8);

    canvas.drawCircle(Offset(x, y), breached ? 15 : 10, glowPaint);

    // Inner circle
    canvas.drawCircle(Offset(x, y), 5, paint);

    // Pulse ring if breached
    if (breached) {
      final pulsePaint = Paint()
        ..color = Colors.red.withOpacity(1 - glowAnimation)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(x, y), 5 + (10 * glowAnimation), pulsePaint);
    }
  }

  void _drawCameras(Canvas canvas, double centerX, double centerY, double angle) {
    final cameraPositions = [
      Offset(centerX - 90, centerY - 20),
      Offset(centerX + 90, centerY - 20),
      Offset(centerX + 120, centerY + 10),
    ];

    final cameraPaint = Paint()
      ..color = Color(0xFF0575E6);

    for (var pos in cameraPositions) {
      // Camera body
      canvas.drawCircle(pos, 6, cameraPaint);

      // Camera lens
      final lensPaint = Paint()
        ..color = Color(0xFF00F260);
      canvas.drawCircle(pos, 3, lensPaint);

      // Camera glow
      final glowPaint = Paint()
        ..color = Color(0xFF0575E6).withOpacity(0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, 10, glowPaint);

      // Recording indicator
      if (cameras.isNotEmpty && cameras[0].recording) {
        final recPaint = Paint()
          ..color = Colors.red.withOpacity(glowAnimation);
        canvas.drawCircle(Offset(pos.dx + 6, pos.dy - 6), 2, recPaint);
      }
    }
  }

  void _drawBreachWarnings(Canvas canvas, double centerX, double centerY) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '⚠️ BREACH',
        style: TextStyle(
          color: Colors.red,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - 50, centerY - 130));
  }

  @override
  bool shouldRepaint(Enhanced3DHousePainter oldDelegate) => true;
}