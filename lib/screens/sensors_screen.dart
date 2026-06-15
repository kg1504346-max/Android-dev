import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

class SensorsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (context, securityProvider, child) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sensors Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: securityProvider.sensors.length + 1,
                  itemBuilder: (context, index) {
                    if (index == securityProvider.sensors.length) {
                      // Info card at the bottom
                      return Container(
                        margin: EdgeInsets.only(top: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          border: Border.all(color: Colors.blue[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.blue[800],
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tip: Tap any sensor to simulate a breach/reset. This will trigger alerts and automatic camera recording.',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final sensor = securityProvider.sensors[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          // Haptic feedback
                          HapticFeedback.mediumImpact();
                          securityProvider.handleSensorBreach(sensor.id);

                          // Show snackbar feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                sensor.breached
                                    ? 'Sensor Reset: ${sensor.location}'
                                    : 'BREACH DETECTED: ${sensor.location}',
                              ),
                              backgroundColor: sensor.breached
                                  ? Colors.green[600]
                                  : Colors.red[600],
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: sensor.breached
                                ? Border.all(color: Colors.red, width: 2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: sensor.breached
                                              ? Colors.red[100]
                                              : sensor.status == 'active'
                                              ? Colors.green[100]
                                              : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          sensor.breached
                                              ? Icons.warning
                                              : Icons.sensors,
                                          color: sensor.breached
                                              ? Colors.red[600]
                                              : sensor.status == 'active'
                                              ? Colors.green[600]
                                              : Colors.grey[600],
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sensor.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            sensor.location,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (sensor.breached)
                                            Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning,
                                                    color: Colors.red[600],
                                                    size: 12,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'BREACHED - Tap to Reset',
                                                    style: TextStyle(
                                                      color: Colors.red[600],
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: sensor.breached
                                                  ? Colors.red
                                                  : sensor.status == 'active'
                                                  ? Colors.green
                                                  : Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            sensor.breached
                                                ? 'BREACHED'
                                                : sensor.status.toUpperCase(),
                                            style: TextStyle(
                                              color: sensor.breached
                                                  ? Colors.red[600]
                                                  : Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: sensor.breached
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (sensor.breached)
                                        Container(
                                          margin: EdgeInsets.only(top: 4),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'ALERT ACTIVE',
                                            style: TextStyle(
                                              color: Colors.red[800],
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),

                              // Battery Level
                              Row(
                                children: [
                                  Icon(
                                    Icons.battery_std,
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: sensor.battery / 100,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        sensor.battery > 70
                                            ? Colors.green
                                            : sensor.battery > 30
                                            ? Colors.orange
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${sensor.battery}%',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              // Breach Details (if breached)
                              if (sensor.breached)
                                Container(
                                  margin: EdgeInsets.only(top: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Breach Details:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[800],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow('Time', DateTime.now().toString().substring(11, 19)),
                                          _buildDetailRow('Location', sensor.location),
                                          _buildDetailRow('Type', 'Security Breach Detected'),
                                          _buildDetailRow('Camera Recording', 'Auto-triggered'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(
        '• $label: $value',
        style: TextStyle(
          color: Colors.red[700],
          fontSize: 12,
        ),
      ),
    );
  }
}