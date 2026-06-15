import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/notification_service.dart';

class SecurityProvider with ChangeNotifier {
  bool _systemArmed = false;
  bool _doorLocked = true;
  Timer? _simulationTimer;

  final NotificationService _notificationService = NotificationService();

  List<SecurityAlert> _alerts = [
    SecurityAlert(
      id: '1',
      type: 'motion',
      location: 'Front Door',
      time: '2 min ago',
      severity: 'medium',
    ),
    SecurityAlert(
      id: '2',
      type: 'door',
      location: 'Back Door',
      time: '5 min ago',
      severity: 'low',
    ),
  ];

  List<Camera> _cameras = [
    Camera(id: '1', name: 'Front Door', status: 'online', recording: true),
    Camera(id: '2', name: 'Living Room', status: 'online', recording: false),
    Camera(id: '3', name: 'Backyard', status: 'offline', recording: false),
    Camera(id: '4', name: 'Garage', status: 'online', recording: true),
  ];

  List<Sensor> _sensors = [
    Sensor(id: '1', name: 'Motion Sensor - Entry', status: 'active', battery: 85, location: 'Front Door'),
    Sensor(id: '2', name: 'Door Sensor - Main', status: 'active', battery: 92, location: 'Main Door'),
    Sensor(id: '3', name: 'Window Sensor - Living', status: 'inactive', battery: 67, location: 'Living Room'),
    Sensor(id: '4', name: 'Glass Break Sensor', status: 'active', battery: 78, location: 'Kitchen'),
    Sensor(id: '5', name: 'Motion Sensor - Kitchen', status: 'active', battery: 91, location: 'Kitchen'),
    Sensor(id: '6', name: 'Door Sensor - Back', status: 'active', battery: 73, location: 'Back Door'),
    Sensor(id: '7', name: 'Window Sensor - Bedroom', status: 'active', battery: 88, location: 'Master Bedroom'),
    Sensor(id: '8', name: 'Motion Sensor - Hallway', status: 'active', battery: 65, location: 'Hallway'),
    Sensor(id: '9', name: 'Door Sensor - Garage', status: 'inactive', battery: 82, location: 'Garage'),
    Sensor(id: '10', name: 'Window Sensor - Bathroom', status: 'active', battery: 76, location: 'Bathroom'),
    Sensor(id: '11', name: 'Motion Sensor - Basement', status: 'active', battery: 54, location: 'Basement'),
    Sensor(id: '12', name: 'Glass Break - Patio', status: 'active', battery: 89, location: 'Patio Door'),
  ];

  List<ArchiveRecord> _archives = [
    ArchiveRecord(
      id: '1',
      camera: 'Front Door',
      timestamp: '2024-09-27 08:30:15',
      duration: '00:02:45',
      detections: ['Human', 'Vehicle'],
      thumbnail: 'recording1',
      type: 'motion_triggered',
    ),
    ArchiveRecord(
      id: '2',
      camera: 'Backyard',
      timestamp: '2024-09-27 07:15:22',
      duration: '00:01:32',
      detections: ['Animal - Cat'],
      thumbnail: 'recording2',
      type: 'motion_triggered',
    ),
    ArchiveRecord(
      id: '3',
      camera: 'Living Room',
      timestamp: '2024-09-27 06:45:10',
      duration: '00:03:18',
      detections: ['Human', 'Pet - Dog'],
      thumbnail: 'recording3',
      type: 'scheduled',
    ),
    ArchiveRecord(
      id: '4',
      camera: 'Garage',
      timestamp: '2024-09-26 22:30:45',
      duration: '00:04:12',
      detections: ['Human', 'Vehicle'],
      thumbnail: 'recording4',
      type: 'breach_triggered',
    ),
  ];

  bool get systemArmed => _systemArmed;
  bool get doorLocked => _doorLocked;
  List<SecurityAlert> get alerts => _alerts;
  List<Camera> get cameras => _cameras;
  List<Sensor> get sensors => _sensors;
  List<ArchiveRecord> get archives => _archives;

  SecurityProvider() {
    _startSimulation();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    await _notificationService.initialize();
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (Random().nextDouble() > 0.95) {
        _generateRandomAlert();
      }
    });
  }

  void _generateRandomAlert() {
    final types = ['motion', 'door', 'window'];
    final locations = ['Front Door', 'Back Door', 'Living Room', 'Kitchen', 'Master Bedroom', 'Hallway', 'Garage', 'Bathroom', 'Basement', 'Patio Door'];
    final severities = ['low', 'medium', 'high'];

    final newAlert = SecurityAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: types[Random().nextInt(types.length)],
      location: locations[Random().nextInt(locations.length)],
      time: 'Just now',
      severity: severities[Random().nextInt(severities.length)],
    );

    _alerts.insert(0, newAlert);
    if (_alerts.length > 5) {
      _alerts.removeLast();
    }
    notifyListeners();
  }

  void toggleSystemArmed() {
    _systemArmed = !_systemArmed;
    notifyListeners();
  }

  void toggleDoorLock() {
    _doorLocked = !_doorLocked;
    notifyListeners();
  }

  void handleSensorBreach(String sensorId) {
    final sensorIndex = _sensors.indexWhere((s) => s.id == sensorId);
    if (sensorIndex != -1) {
      final sensor = _sensors[sensorIndex];
      sensor.breached = !sensor.breached;
      sensor.status = sensor.breached ? 'breached' : 'active';

      if (sensor.breached) {
        _notificationService.showBreachNotification(sensor.location, sensor.name);

        final breachAlert = SecurityAlert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'breach',
          location: sensor.location,
          time: 'Just now',
          severity: 'high',
        );
        _alerts.insert(0, breachAlert);

        final possibleDetections = [
          ['Human', 'Motion'],
          ['Human', 'Vehicle'],
          ['Human', 'Pet - Dog'],
          ['Animal - Cat'],
          ['Vehicle', 'Motion'],
        ];

        final randomDetections = possibleDetections[DateTime.now().millisecond % possibleDetections.length];

        final newArchive = ArchiveRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          camera: sensor.location,
          timestamp: DateTime.now().toString().substring(0, 19),
          duration: '00:0${30 + (DateTime.now().second % 60)}',
          detections: randomDetections,
          thumbnail: 'breach_${DateTime.now().millisecondsSinceEpoch}',
          type: 'breach_triggered',
        );
        _archives.insert(0, newArchive);

        final cameraIndex = _cameras.indexWhere((c) => c.name == sensor.location);
        if (cameraIndex != -1) {
          _cameras[cameraIndex].recording = true;
        }
      } else {
        final cameraIndex = _cameras.indexWhere((c) => c.name == sensor.location);
        if (cameraIndex != -1) {
          _cameras[cameraIndex].recording = false;
        }
      }

      notifyListeners();
    }
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}