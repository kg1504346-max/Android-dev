import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../providers/security_provider.dart';

class AdvancedSimulationCenter extends StatefulWidget {
  @override
  _AdvancedSimulationCenterState createState() => _AdvancedSimulationCenterState();
}

class _AdvancedSimulationCenterState extends State<AdvancedSimulationCenter>
    with TickerProviderStateMixin {
  bool _isSimulationRunning = false;
  List<SimulationLog> _simulationLogs = [];
  Timer? _simulationTimer;
  String _currentScenario = 'None';
  int _simulationStep = 0;

  // Hardware sensor simulation values with realistic ranges
  double _temperatureSensor = 22.5;
  double _humiditySensor = 45.0;
  int _lightLevelSensor = 750;
  double _soundLevelSensor = 35.0;
  bool _smokeSensor = false;
  bool _gasSensor = false;
  double _motionSensorVoltage = 3.2;
  double _doorSensorGap = 0.0;
  double _windowSensorMagnetic = 0.0;
  int _pirHeatSignature = 0;
  double _glassBreakFrequency = 0.0;

  // Network simulation
  int _networkLatency = 15;
  double _signalStrength = -45.0;
  int _packetsSent = 0;
  int _packetsReceived = 0;

  // Power consumption simulation
  double _systemVoltage = 12.0;
  double _currentDraw = 0.45;

  // Vibration simulation tracking
  int _vibrationCount = 0;
  String _lastVibrationType = 'None';

  late AnimationController _waveController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _startNetworkSimulation();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startNetworkSimulation() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _networkLatency = 15 + Random().nextInt(10);
          _signalStrength = -45.0 + Random().nextDouble() * 10;
          if (_isSimulationRunning) {
            _packetsSent += Random().nextInt(5) + 1;
            _packetsReceived += Random().nextInt(5) + 1;
          }
        });
      }
    });
  }

  void _addLog(String message, LogType type, {Map<String, dynamic>? data}) {
    setState(() {
      _simulationLogs.insert(0, SimulationLog(
        timestamp: DateTime.now(),
        message: message,
        type: type,
        data: data,
      ));
      if (_simulationLogs.length > 100) _simulationLogs.removeLast();
    });
  }

  void _clearLogs() {
    setState(() {
      _simulationLogs.clear();
    });
  }

  // Simulate device vibration with feedback
  Future<void> _simulateVibration(String vibrationType) async {
    setState(() {
      _vibrationCount++;
      _lastVibrationType = vibrationType;
    });

    switch (vibrationType) {
      case 'light':
        await HapticFeedback.lightImpact();
        _addLog('📳 Vibration Output: Light Impact (50ms)', LogType.output,
            data: {
              'type': 'Light Haptic',
              'duration': '50ms',
              'intensity': '30%',
              'hardware': 'Linear Actuator/Vibration Motor',
            });
        break;

      case 'medium':
        await HapticFeedback.mediumImpact();
        _addLog('📳 Vibration Output: Medium Impact (100ms)', LogType.output,
            data: {
              'type': 'Medium Haptic',
              'duration': '100ms',
              'intensity': '60%',
              'hardware': 'Taptic Engine',
            });
        break;

      case 'heavy':
        await HapticFeedback.heavyImpact();
        _addLog('📳 Vibration Output: Heavy Impact (150ms)', LogType.output,
            data: {
              'type': 'Heavy Haptic',
              'duration': '150ms',
              'intensity': '100%',
              'hardware': 'Vibration Motor - Full Power',
            });
        break;

      case 'breach_triple':
      // Triple vibration pattern for critical breach
        await HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 200));
        await HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 200));
        await HapticFeedback.heavyImpact();
        _addLog('📳 CRITICAL Vibration Pattern: Triple Heavy', LogType.critical,
            data: {
              'pattern': 'Heavy-Pause-Heavy-Pause-Heavy',
              'total_duration': '550ms',
              'intensity': '100%',
              'purpose': 'Security Breach Alert',
              'hardware': 'ERM Vibration Motor'
            });
        break;

      case 'alarm_continuous':
      // Simulated continuous vibration
        for (int i = 0; i < 3; i++) {
          await HapticFeedback.heavyImpact();
          await Future.delayed(Duration(milliseconds: 100));
        }
        _addLog('📳 Alarm Vibration: Continuous Pattern', LogType.warning,
            data: {
              'pattern': 'Pulsing (3 cycles)',
              'frequency': '10 Hz',
              'duty_cycle': '50%',
              'purpose': 'Fire/Emergency Alarm',
            });
        break;

      default:
        await HapticFeedback.selectionClick();
    }
  }

  void _runCompleteBreachScenario(BuildContext context) {
    final provider = Provider.of<SecurityProvider>(context, listen: false);
    setState(() {
      _isSimulationRunning = true;
      _currentScenario = 'Complete Home Intrusion Simulation';
      _simulationStep = 0;
    });

    _addLog('═══════════════════════════════════════', LogType.system);
    _addLog('🎬 STARTING COMPLETE BREACH SCENARIO', LogType.scenario);
    _addLog('Simulating real-world break-in attempt', LogType.info);
    _addLog('═══════════════════════════════════════', LogType.system);

    _simulationTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _simulationStep++;

      switch (_simulationStep) {
        case 1:
          _addLog('⏰ TIME: 02:15 AM - System in Night Mode', LogType.info);
          _addLog('🌙 Light Sensor Reading', LogType.input,
              data: {'value': '50 lux', 'voltage': '1.2V', 'hardware': 'LDR GL5528'});
          setState(() => _lightLevelSensor = 50);
          break;

        case 2:
          _addLog('🚶 STAGE 1: Perimeter Approach Detected', LogType.warning);
          _simulateVibration('light');
          _addLog('📊 Motion Sensor - Front Yard', LogType.input,
              data: {
                'voltage': '3.2V → 4.8V',
                'hardware': 'PIR HC-SR501',
                'sensitivity': 'High',
                'range': '7 meters'
              });
          setState(() => _motionSensorVoltage = 4.8);
          break;

        case 3:
          _addLog('🎯 AI Camera Analysis - Front Door', LogType.processing);
          _addLog('🤖 Running Object Detection Model', LogType.processing);
          Future.delayed(Duration(milliseconds: 500), () {
            _addLog('✓ Detection: HUMAN (Confidence: 94%)', LogType.output,
                data: {
                  'detection': 'Human',
                  'confidence': '94%',
                  'height': '175cm',
                  'clothing': 'Dark hoodie',
                  'behavior': 'Suspicious'
                });
          });
          break;

        case 4:
          _addLog('🚨 BREACH ATTEMPT: Front Door', LogType.critical);
          _simulateVibration('breach_triple');
          _addLog('📊 Magnetic Door Sensor', LogType.input,
              data: {
                'gap': '0mm → 25mm',
                'hardware': 'Reed Switch MC-38',
                'voltage': '5V → 0V (Open)',
                'status': 'BREACHED'
              });
          setState(() => _doorSensorGap = 25.0);
          provider.handleSensorBreach('2');

          _addLog('📤 Emergency Alert Packet Sent', LogType.output,
              data: {
                'protocol': 'MQTT over TLS',
                'destination': 'Mobile App + Cloud',
                'priority': 'CRITICAL',
                'latency': '${_networkLatency}ms'
              });
          break;

        case 5:
          _addLog('📹 Automated Response Triggered', LogType.processing);
          _simulateVibration('medium');
          _addLog('📤 Starting Video Recording', LogType.output,
              data: {
                'cameras': '4 units',
                'resolution': '1080p @ 30fps',
                'codec': 'H.264',
                'storage': 'Local NVR + Cloud Backup'
              });

          _addLog('🔊 Alarm Siren Activated', LogType.output,
              data: {
                'decibel': '110 dB',
                'frequency': '3kHz',
                'hardware': 'Piezo Speaker'
              });
          setState(() => _soundLevelSensor = 110.0);
          break;

        case 6:
          _addLog('🚪 STAGE 2: Interior Breach Detected', LogType.critical);
          _simulateVibration('heavy');
          _addLog('📊 Living Room Motion Sensor', LogType.input,
              data: {
                'type': 'PIR Heat Signature',
                'value': '98.6°F detected',
                'hardware': 'AMN31111',
                'range': 'Active'
              });
          setState(() => _pirHeatSignature = 99);
          provider.handleSensorBreach('3');
          break;

        case 7:
          _addLog('🪟 Window Sensor Alert - Bedroom', LogType.warning);
          _addLog('📊 Magnetic Contact Sensor', LogType.input,
              data: {
                'gap': '0mm → 15mm',
                'hardware': 'Surface Mount Contact',
                'tamper': 'No',
                'battery': '3.0V'
              });
          setState(() => _windowSensorMagnetic = 15.0);
          break;

        case 8:
          _addLog('💾 Recording Archive Created', LogType.output,
              data: {
                'duration': '45 seconds',
                'file_size': '12.3 MB',
                'format': 'MP4/H.264',
                'ai_tags': 'Human, Intrusion, Night'
              });
          break;

        case 9:
          _addLog('📞 Emergency Contacts Notified', LogType.output,
              data: {
                'sms_sent': '3 contacts',
                'push_notifications': 'Delivered',
                'email_alerts': 'Queued',
                'police_notification': 'Pending Confirmation'
              });
          break;

        case 10:
          _addLog('═══════════════════════════════════════', LogType.system);
          _addLog('✅ SCENARIO COMPLETE', LogType.success);
          _addLog('Total Response Time: ${_simulationStep * 2} seconds', LogType.info);
          _addLog('All systems responded correctly', LogType.success);
          _addLog('═══════════════════════════════════════', LogType.system);

          _generateSimulationReport();
          setState(() {
            _isSimulationRunning = false;
            _currentScenario = 'Completed Successfully';
          });
          timer.cancel();
          break;
      }
    });
  }

  void _runEnvironmentalScenario(BuildContext context) {
    setState(() {
      _isSimulationRunning = true;
      _currentScenario = 'Fire & Environmental Hazard Detection';
      _simulationStep = 0;
    });

    _addLog('═══════════════════════════════════════', LogType.system);
    _addLog('🔥 STARTING FIRE DETECTION SCENARIO', LogType.scenario);
    _addLog('═══════════════════════════════════════', LogType.system);

    _simulationTimer = Timer.periodic(Duration(milliseconds: 1800), (timer) {
      _simulationStep++;

      switch (_simulationStep) {
        case 1:
          _addLog('🌡️ Temperature Rise Detected - Kitchen', LogType.warning);
          _simulateVibration('light');
          setState(() => _temperatureSensor = 28.5);
          _addLog('📊 NTC Thermistor Input', LogType.input,
              data: {
                'temperature': '22.5°C → 28.5°C',
                'resistance': '10kΩ → 7.5kΩ',
                'hardware': 'NTC 10K β3950',
                'adc_value': '512 → 420'
              });
          break;

        case 2:
          setState(() => _temperatureSensor = 45.0);
          _simulateVibration('heavy');
          _addLog('🔥 CRITICAL: Rapid Temperature Increase', LogType.critical,
              data: {
                'temperature': '45°C',
                'rate': '+8.25°C per minute',
                'threshold': '40°C (Exceeded)',
                'resistance': '2.5kΩ'
              });
          break;

        case 3:
          _addLog('💨 Smoke Detection Activated', LogType.critical);
          _simulateVibration('breach_triple');
          setState(() => _smokeSensor = true);
          _addLog('📊 MQ-2 Smoke Sensor', LogType.input,
              data: {
                'analog_output': '0.2V → 4.5V',
                'ppm': '200 ppm (High)',
                'hardware': 'MQ-2 Gas Sensor',
                'warmup_time': '20s',
                'status': 'SMOKE DETECTED'
              });
          break;

        case 4:
          _addLog('📤 Fire Emergency Protocol Initiated', LogType.critical);
          _simulateVibration('alarm_continuous');
          _addLog('🔊 Fire Alarm Siren - 120dB', LogType.output,
              data: {
                'all_zones': 'Activated',
                'frequency': '3.2kHz Pulsing',
                'duration': 'Continuous until reset'
              });
          break;

        case 5:
          _addLog('🚨 Emergency Services Alert', LogType.output,
              data: {
                'fire_department': 'Notification Sent',
                'address': 'GPS Coordinates Included',
                'residents': '3 mobile alerts sent',
                'neighbors': 'Community alert active'
              });
          break;

        case 6:
          _addLog('💨 Air Quality Monitoring', LogType.input,
              data: {
                'co_level': '50 ppm',
                'co2_level': '1200 ppm',
                'voc': 'Elevated',
                'hardware': 'MQ-7 & MQ-135'
              });
          setState(() => _gasSensor = true);
          break;

        case 7:
          _addLog('✅ All Safety Protocols Executed', LogType.success);
          _addLog('Total Alert Time: ${_simulationStep * 1.8} seconds', LogType.info);
          _generateSimulationReport();
          setState(() {
            _isSimulationRunning = false;
            _currentScenario = 'Completed';
            _temperatureSensor = 22.5;
            _smokeSensor = false;
            _gasSensor = false;
          });
          timer.cancel();
          break;
      }
    });
  }

  void _runNetworkFailureScenario(BuildContext context) {
    setState(() {
      _isSimulationRunning = true;
      _currentScenario = 'Network Failure & Recovery Test';
      _simulationStep = 0;
    });

    _addLog('═══════════════════════════════════════', LogType.system);
    _addLog('📡 TESTING NETWORK RESILIENCE', LogType.scenario);
    _addLog('═══════════════════════════════════════', LogType.system);

    _simulationTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _simulationStep++;

      switch (_simulationStep) {
        case 1:
          _addLog('📡 Normal Network Operation', LogType.info,
              data: {
                'wifi_signal': '-45 dBm (Excellent)',
                'latency': '15ms',
                'bandwidth': '50 Mbps',
                'packet_loss': '0%'
              });
          break;

        case 2:
          _addLog('⚠️ Network Connection Lost', LogType.critical);
          _simulateVibration('heavy');
          setState(() {
            _signalStrength = -90.0;
            _networkLatency = 999;
          });
          _addLog('📊 Network Diagnostics', LogType.input,
              data: {
                'wifi_signal': '-90 dBm (No signal)',
                'router_ping': 'Failed',
                'cloud_connection': 'Offline',
                'cause': 'Simulated ISP outage'
              });
          break;

        case 3:
          _addLog('💾 Activating Local Storage Mode', LogType.processing);
          _addLog('📤 Buffering Events Locally', LogType.output,
              data: {
                'mode': 'Offline Operation',
                'storage': 'Local SQLite DB',
                'capacity': '500 events',
                'recording': 'Continuous to SD card'
              });
          break;

        case 4:
          _addLog('📡 Attempting Cellular Backup', LogType.processing);
          _addLog('📊 4G LTE Module', LogType.input,
              data: {
                'module': 'SIM7600',
                'signal': '3 bars',
                'operator': 'Backup Network',
                'status': 'Connected'
              });
          break;

        case 5:
          _addLog('✅ Failover Complete - Using Cellular', LogType.success);
          _simulateVibration('medium');
          setState(() {
            _signalStrength = -65.0;
            _networkLatency = 45;
          });
          _addLog('📤 Uploading Buffered Data', LogType.output,
              data: {
                'events': '23 buffered events',
                'size': '1.2 MB',
                'time': '8 seconds',
                'status': 'Synchronized'
              });
          break;

        case 6:
          _addLog('📡 Primary WiFi Restored', LogType.success);
          setState(() {
            _signalStrength = -45.0;
            _networkLatency = 15;
          });
          _addLog('🔄 Switching Back to Primary Network', LogType.processing);
          break;

        case 7:
          _addLog('✅ Network Resilience Test Complete', LogType.success);
          _addLog('System maintained operation during outage', LogType.info);
          _addLog('Zero data loss confirmed', LogType.success);
          _generateSimulationReport();
          setState(() {
            _isSimulationRunning = false;
            _currentScenario = 'Completed';
          });
          timer.cancel();
          break;
      }
    });
  }

  void _runPowerFailureScenario(BuildContext context) {
    setState(() {
      _isSimulationRunning = true;
      _currentScenario = 'Power Failure & Battery Backup Test';
      _simulationStep = 0;
    });

    _addLog('═══════════════════════════════════════', LogType.system);
    _addLog('🔋 TESTING POWER BACKUP SYSTEM', LogType.scenario);
    _addLog('═══════════════════════════════════════', LogType.system);

    _simulationTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _simulationStep++;

      switch (_simulationStep) {
        case 1:
          _addLog('⚡ Normal Power Operation', LogType.info,
              data: {
                'input_voltage': '230V AC',
                'frequency': '50Hz',
                'power_supply': '12V DC / 3A',
                'status': 'Stable'
              });
          setState(() => _systemVoltage = 12.0);
          break;

        case 2:
          _addLog('⚠️ MAIN POWER FAILURE DETECTED', LogType.critical);
          _simulateVibration('heavy');
          _addLog('📊 Voltage Monitor', LogType.input,
              data: {
                'ac_input': '230V → 0V',
                'detection_time': '20ms',
                'hardware': 'ACS712 Current Sensor',
                'trigger': 'Under-voltage lockout'
              });
          break;

        case 3:
          _addLog('🔋 Switching to Battery Backup', LogType.processing);
          _addLog('📊 Battery Management System', LogType.output,
              data: {
                'battery_type': 'Li-ion 12V 7Ah',
                'voltage': '12.6V',
                'capacity': '95%',
                'estimated_runtime': '8 hours',
                'switch_time': '<50ms'
              });
          setState(() => _systemVoltage = 12.6);
          break;

        case 4:
          _addLog('✅ Seamless Transition Complete', LogType.success);
          _addLog('All systems operational on battery', LogType.info);
          _addLog('📤 Power Failure Alert Sent', LogType.output,
              data: {
                'notification': 'Mobile app',
                'message': 'Running on battery backup',
                'estimated_runtime': '8 hours'
              });
          break;

        case 5:
          _addLog('💾 Entering Power-Save Mode', LogType.processing);
          _addLog('📤 System Optimization', LogType.output,
              data: {
                'cameras': '2/4 active (essential only)',
                'recording': 'Motion-triggered only',
                'wifi': 'Low power mode',
                'current_draw': '0.45A → 0.28A'
              });
          setState(() => _currentDraw = 0.28);
          break;

        case 6:
          _addLog('⚡ Main Power Restored', LogType.success);
          _simulateVibration('light');
          _addLog('🔋 Switching Back & Charging Battery', LogType.processing,
              data: {
                'ac_input': '230V restored',
                'charging_current': '1.5A',
                'full_charge_time': '3 hours',
                'status': 'Charging'
              });
          setState(() {
            _systemVoltage = 12.0;
            _currentDraw = 0.45;
          });
          break;

        case 7:
          _addLog('✅ Power Resilience Test Complete', LogType.success);
          _addLog('Uninterrupted operation confirmed', LogType.info);
          _generateSimulationReport();
          setState(() {
            _isSimulationRunning = false;
            _currentScenario = 'Completed';
          });
          timer.cancel();
          break;
      }
    });
  }

  void _generateSimulationReport() {
    _addLog('', LogType.system);
    _addLog('📊 ═══════ SIMULATION REPORT ═══════', LogType.system);
    _addLog('Scenario: $_currentScenario', LogType.info);
    _addLog('Duration: ${_simulationStep * 2} seconds', LogType.info);
    _addLog('Total Steps: $_simulationStep', LogType.info);
    _addLog('Packets Sent: $_packetsSent', LogType.info);
    _addLog('Packets Received: $_packetsReceived', LogType.info);
    _addLog('Network Latency: ${_networkLatency}ms', LogType.info);
    _addLog('System Voltage: ${_systemVoltage.toStringAsFixed(1)}V', LogType.info);
    _addLog('Vibrations Triggered: $_vibrationCount', LogType.info);
    _addLog('Status: ✅ ALL TESTS PASSED', LogType.success);
    _addLog('═══════════════════════════════════════', LogType.system);
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    setState(() {
      _isSimulationRunning = false;
      _currentScenario = 'Stopped by User';
    });
    _addLog('⏹️ Simulation stopped by user', LogType.warning);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatusCard(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHardwareMetrics(),
                      SizedBox(height: 16),
                      _buildNetworkMetrics(),
                      SizedBox(height: 16),
                      _buildScenarioButtons(context),
                      SizedBox(height: 16),
                      _buildSimulationLogs(),
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
                  'Advanced Simulation Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Hardware/Software I/O Testing Lab',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (_isSimulationRunning)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(_pulseController.value),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 6),
                  Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Scenario:',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    _currentScenario,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isSimulationRunning)
                    Text(
                      'Step $_simulationStep',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                ],
              ),
              if (_isSimulationRunning)
                ElevatedButton.icon(
                  onPressed: _stopSimulation,
                  icon: Icon(Icons.stop),
                  label: Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          if (_isSimulationRunning) ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: null,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHardwareMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hardware Sensor Inputs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.memory, color: Colors.white70, size: 20),
          ],
        ),
        SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildMetricCard(
              '🌡️ Temperature',
              '${_temperatureSensor.toStringAsFixed(1)}°C',
              _temperatureSensor > 40 ? Colors.red : Colors.green,
              'NTC 10K Thermistor',
              '${(10000 * exp(-3950 * (_temperatureSensor - 25) / 298.15)).toStringAsFixed(0)}Ω',
            ),
            _buildMetricCard(
              '💧 Humidity',
              '${_humiditySensor.toStringAsFixed(0)}%',
              Colors.blue,
              'DHT22 Sensor',
              '${(3.3 * _humiditySensor / 100).toStringAsFixed(2)}V',
            ),
            _buildMetricCard(
              '💡 Light Level',
              '$_lightLevelSensor lux',
              _lightLevelSensor < 200 ? Colors.orange : Colors.yellow,
              'GL5528 LDR',
              '${(50000 / (_lightLevelSensor + 1)).toStringAsFixed(0)}Ω',
            ),
            _buildMetricCard(
              '🔊 Sound Level',
              '${_soundLevelSensor.toStringAsFixed(0)} dB',
              _soundLevelSensor > 80 ? Colors.red : Colors.purple,
              'MAX4466 Mic',
              '${(3.3 * _soundLevelSensor / 120).toStringAsFixed(2)}V',
            ),
            _buildMetricCard(
              '💨 Smoke Sensor',
              _smokeSensor ? 'DETECTED' : 'Clear',
              _smokeSensor ? Colors.red : Colors.green,
              'MQ-2 Module',
              _smokeSensor ? '4.5V' : '0.2V',
            ),
            _buildMetricCard(
              '⚠️ Gas Sensor',
              _gasSensor ? 'LEAK' : 'Safe',
              _gasSensor ? Colors.red : Colors.green,
              'MQ-5 Module',
              _gasSensor ? '3.8V' : '0.3V',
            ),
            _buildMetricCard(
              '🚶 Motion (PIR)',
              '${_motionSensorVoltage.toStringAsFixed(1)}V',
              _motionSensorVoltage > 4.0 ? Colors.red : Colors.green,
              'HC-SR501',
              _motionSensorVoltage > 4.0 ? 'ACTIVE' : 'IDLE',
            ),
            _buildMetricCard(
              '🚪 Door Gap',
              '${_doorSensorGap.toStringAsFixed(0)}mm',
              _doorSensorGap > 5 ? Colors.red : Colors.green,
              'Reed Switch MC-38',
              _doorSensorGap > 5 ? 'OPEN' : 'CLOSED',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, String hardware, String detail) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            hardware,
            style: TextStyle(color: Colors.white60, fontSize: 9),
          ),
          Text(
            detail,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkMetrics() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Metrics & Outputs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.router, color: Colors.white70, size: 20),
            ],
          ),
          SizedBox(height: 12),

          // Network Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildSmallMetric('Signal', '${_signalStrength.toStringAsFixed(0)} dBm',
                    _signalStrength > -60 ? Colors.green : Colors.orange),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildSmallMetric('Latency', '${_networkLatency}ms',
                    _networkLatency < 50 ? Colors.green : Colors.red),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Data Transfer Row
          Row(
            children: [
              Expanded(
                child: _buildSmallMetric('TX', '$_packetsSent pkts', Colors.blue),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildSmallMetric('RX', '$_packetsReceived pkts', Colors.cyan),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Power Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildSmallMetric('Voltage', '${_systemVoltage.toStringAsFixed(1)}V', Colors.green),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildSmallMetric('Current', '${_currentDraw.toStringAsFixed(2)}A', Colors.yellow),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Vibration Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildSmallMetric('Vibrations', '$_vibrationCount', Colors.purple),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.pink.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.vibration, color: Colors.pink, size: 12),
                          SizedBox(width: 4),
                          Text('Last Type', style: TextStyle(color: Colors.white70, fontSize: 9)),
                        ],
                      ),
                      Text(
                        _lastVibrationType,
                        style: TextStyle(color: Colors.pink, fontSize: 10, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetric(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildScenarioButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Test Scenarios',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color(0xFF1A1F3A),
                          title: Text('Test Vibration Patterns', style: TextStyle(color: Colors.white)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _simulateVibration('light');
                                },
                                child: Text('Light Vibration'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _simulateVibration('medium');
                                },
                                child: Text('Medium Vibration'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _simulateVibration('heavy');
                                },
                                child: Text('Heavy Vibration'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _simulateVibration('breach_triple');
                                },
                                child: Text('Triple Breach Pattern'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _simulateVibration('alarm_continuous');
                                },
                                child: Text('Alarm Pattern'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Close', style: TextStyle(color: Colors.cyan)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.vibration, color: Colors.pink, size: 16),
                  label: Text('Test Vibration', style: TextStyle(color: Colors.pink, fontSize: 12)),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _clearLogs,
                  icon: Icon(Icons.delete_outline, color: Colors.white70, size: 16),
                  label: Text('Clear Logs', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        _buildScenarioButton(
          'Complete Home Intrusion',
          'Full breach scenario with sensors, AI detection & vibration alerts',
          Icons.home_outlined,
          Colors.red,
              () => _runCompleteBreachScenario(context),
        ),
        SizedBox(height: 10),
        _buildScenarioButton(
          'Fire & Environmental Hazard',
          'Temperature, smoke & gas sensors with emergency vibration protocols',
          Icons.local_fire_department,
          Colors.orange,
              () => _runEnvironmentalScenario(context),
        ),
        SizedBox(height: 10),
        _buildScenarioButton(
          'Network Failure & Recovery',
          'Tests WiFi failure, cellular failover & data synchronization',
          Icons.wifi_off,
          Colors.purple,
              () => _runNetworkFailureScenario(context),
        ),
        SizedBox(height: 10),
        _buildScenarioButton(
          'Power Failure & Battery Backup',
          'Tests UPS system, battery backup & power-save mode',
          Icons.battery_alert,
          Colors.amber,
              () => _runPowerFailureScenario(context),
        ),
      ],
    );
  }

  Widget _buildScenarioButton(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isSimulationRunning ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_isSimulationRunning ? 0.05 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.6), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(
              _isSimulationRunning ? Icons.lock : Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Simulation Logs (Real-time I/O Data)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 400,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.5)),
          ),
          child: _simulationLogs.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.terminal, color: Colors.white30, size: 48),
                SizedBox(height: 12),
                Text(
                  'No simulation logs yet',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Run a test scenario to see detailed I/O data',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _simulationLogs.length,
            itemBuilder: (context, index) {
              final log = _simulationLogs[index];
              return _buildLogEntry(log);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogEntry(SimulationLog log) {
    Color logColor;
    IconData logIcon;

    switch (log.type) {
      case LogType.critical:
        logColor = Colors.red;
        logIcon = Icons.error;
        break;
      case LogType.warning:
        logColor = Colors.orange;
        logIcon = Icons.warning;
        break;
      case LogType.success:
        logColor = Colors.green;
        logIcon = Icons.check_circle;
        break;
      case LogType.input:
        logColor = Colors.cyan;
        logIcon = Icons.input;
        break;
      case LogType.output:
        logColor = Colors.yellow;
        logIcon = Icons.output;
        break;
      case LogType.processing:
        logColor = Colors.purple;
        logIcon = Icons.settings;
        break;
      case LogType.scenario:
        logColor = Colors.blue;
        logIcon = Icons.play_circle_filled;
        break;
      case LogType.system:
        logColor = Colors.grey;
        logIcon = Icons.code;
        break;
      default:
        logColor = Colors.white;
        logIcon = Icons.info;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.timestamp.toString().substring(11, 19),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontFamily: 'Courier',
                ),
              ),
              SizedBox(width: 8),
              Icon(logIcon, color: logColor, size: 12),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  log.message,
                  style: TextStyle(
                    color: logColor,
                    fontSize: 11,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ],
          ),
          if (log.data != null && log.data!.isNotEmpty) ...[
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(left: 64),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: logColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: log.data!.entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(
                        '  ${entry.key}: ${entry.value}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'Courier',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum LogType {
  info,
  warning,
  critical,
  success,
  input,
  output,
  processing,
  scenario,
  system,
}

class SimulationLog {
  final DateTime timestamp;
  final String message;
  final LogType type;
  final Map<String, dynamic>? data;

  SimulationLog({
    required this.timestamp,
    required this.message,
    required this.type,
    this.data,
  });
}