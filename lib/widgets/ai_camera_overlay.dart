import 'package:flutter/material.dart';
import 'dart:math';

class AICameraOverlay extends StatefulWidget {
  final String cameraName;
  final bool isRecording;

  const AICameraOverlay({
    Key? key,
    required this.cameraName,
    this.isRecording = false,
  }) : super(key: key);

  @override
  _AICameraOverlayState createState() => _AICameraOverlayState();
}

class _AICameraOverlayState extends State<AICameraOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  List<FaceDetection> detections = [];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Generate random face detections based on camera
    _generateDetections();
  }

  void _generateDetections() {
    final random = Random();
    final familyNames = ['John Smith', 'Sarah Johnson', 'Mike Davis', 'Emma Wilson'];

    // Different detection patterns for different cameras
    if (widget.cameraName.contains('Front Door')) {
      detections = [
        FaceDetection(
          name: familyNames[random.nextInt(familyNames.length)],
          confidence: 95 + random.nextInt(5),
          isRecognized: true,
          left: 0.2,
          top: 0.25,
          width: 0.25,
          height: 0.35,
        ),
        FaceDetection(
          name: 'Unknown Person',
          confidence: 88 + random.nextInt(10),
          isRecognized: false,
          left: 0.55,
          top: 0.3,
          width: 0.3,
          height: 0.4,
        ),
      ];
    } else if (widget.cameraName.contains('Living Room')) {
      detections = [
        FaceDetection(
          name: familyNames[0],
          confidence: 98,
          isRecognized: true,
          left: 0.3,
          top: 0.2,
          width: 0.28,
          height: 0.38,
        ),
        FaceDetection(
          name: familyNames[1],
          confidence: 96,
          isRecognized: true,
          left: 0.6,
          top: 0.35,
          width: 0.26,
          height: 0.36,
        ),
      ];
    } else if (widget.cameraName.contains('Garage')) {
      detections = [
        FaceDetection(
          name: 'Unknown Person',
          confidence: 92,
          isRecognized: false,
          left: 0.35,
          top: 0.3,
          width: 0.3,
          height: 0.4,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scanning line animation
        AnimatedBuilder(
          animation: _scanController,
          builder: (context, child) {
            return Positioned(
              left: 0,
              right: 0,
              top: _scanController.value * MediaQuery.of(context).size.height * 0.4,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.green,
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Face detection boxes
        ...detections.map((detection) => _buildFaceBox(detection)).toList(),

        // AI Status indicator
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  'AI Detection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Detection count
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              '👤 ${detections.length} Detected',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaceBox(FaceDetection detection) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxLeft = constraints.maxWidth * detection.left;
        final boxTop = constraints.maxHeight * detection.top;
        final boxWidth = constraints.maxWidth * detection.width;
        final boxHeight = constraints.maxHeight * detection.height;

        return Positioned(
          left: boxLeft,
          top: boxTop,
          child: Container(
            width: boxWidth,
            height: boxHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: detection.isRecognized ? Colors.green : Colors.red,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                // Corner markers
                ..._buildCornerMarkers(detection.isRecognized),

                // Name label
                Positioned(
                  top: -28,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          detection.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (detection.isRecognized) ...[
                          SizedBox(width: 4),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 12,
                          ),
                        ] else ...[
                          SizedBox(width: 4),
                          Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Confidence badge
                Positioned(
                  bottom: -24,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${detection.confidence}% ${detection.isRecognized ? "Match" : "Detection"}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCornerMarkers(bool isRecognized) {
    final color = isRecognized ? Colors.green : Colors.red;
    final cornerSize = 15.0;
    final cornerThickness = 3.0;

    return [
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerThickness,
          color: color,
        ),
      ),
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerThickness,
          height: cornerSize,
          color: color,
        ),
      ),
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerThickness,
          color: color,
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerThickness,
          height: cornerSize,
          color: color,
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerThickness,
          color: color,
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerThickness,
          height: cornerSize,
          color: color,
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerThickness,
          color: color,
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerThickness,
          height: cornerSize,
          color: color,
        ),
      ),
    ];
  }
}

class FaceDetection {
  final String name;
  final int confidence;
  final bool isRecognized;
  final double left;
  final double top;
  final double width;
  final double height;

  FaceDetection({
    required this.name,
    required this.confidence,
    required this.isRecognized,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}