import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import 'dashboard_screen.dart';
import 'cameras_screen.dart';
import 'sensors_screen.dart';
import 'alerts_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    CamerasScreen(),
    SensorsScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (context, securityProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SecureHome', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Home Security System', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: securityProvider.systemArmed ? Colors.red[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  securityProvider.systemArmed ? Icons.shield : Icons.security,
                  color: securityProvider.systemArmed ? Colors.red[600] : Colors.green[600],
                  size: 24,
                ),
              ),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: Colors.blue[600],
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Colors.white,
            elevation: 8,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Cameras'),
              BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Sensors'),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Icon(Icons.notifications),
                    if (securityProvider.alerts.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                          constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text('${securityProvider.alerts.length}', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        ),
                      ),
                  ],
                ),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        );
      },
    );
  }
}
