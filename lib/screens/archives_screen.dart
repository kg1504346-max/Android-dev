import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

class ArchivesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Archives',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, securityProvider, child) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: securityProvider.archives.length,
              itemBuilder: (context, index) {
                final archive = securityProvider.archives[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with camera name and type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                archive.camera,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                archive.timestamp,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Duration: ${archive.duration}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(archive.type),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              archive.type.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                color: _getTypeTextColor(archive.type),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Video Thumbnail/Player
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.videocam,
                                color: Colors.grey[600],
                                size: 40,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Text(
                                '📹 Archived Recording',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  // Play video functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Playing archived video...'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.black87,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),

                      // AI Detections
                      Text(
                        'AI Detections:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: archive.detections.map((detection) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDetectionColor(detection),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              detection,
                              style: TextStyle(
                                color: _getDetectionTextColor(detection),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'breach_triggered':
        return Colors.red[100]!;
      case 'motion_triggered':
        return Colors.yellow[100]!;
      case 'scheduled':
        return Colors.blue[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getTypeTextColor(String type) {
    switch (type) {
      case 'breach_triggered':
        return Colors.red[800]!;
      case 'motion_triggered':
        return Colors.yellow[800]!;
      case 'scheduled':
        return Colors.blue[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  Color _getDetectionColor(String detection) {
    if (detection.toLowerCase().contains('human')) {
      return Colors.red[100]!;
    } else if (detection.toLowerCase().contains('animal') ||
        detection.toLowerCase().contains('pet')) {
      return Colors.green[100]!;
    } else if (detection.toLowerCase().contains('vehicle')) {
      return Colors.blue[100]!;
    }
    return Colors.grey[100]!;
  }

  Color _getDetectionTextColor(String detection) {
    if (detection.toLowerCase().contains('human')) {
      return Colors.red[800]!;
    } else if (detection.toLowerCase().contains('animal') ||
        detection.toLowerCase().contains('pet')) {
      return Colors.green[800]!;
    } else if (detection.toLowerCase().contains('vehicle')) {
      return Colors.blue[800]!;
    }
    return Colors.grey[800]!;
  }
}