import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/sensor_data.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../widgets/charts/chart_painter.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'sensor_station_screen.dart';

class SensorMonitoringPage extends StatefulWidget {
  final int areaId;
  const SensorMonitoringPage({super.key, this.areaId = 1});

  @override
  _SensorMonitoringPageState createState() => _SensorMonitoringPageState();
}

class _SensorMonitoringPageState extends State<SensorMonitoringPage> {
  late int selectedArea;
  String selectedSensor = 'temperature';
  Map<int, SensorData> areaData = {};
  Map<String, List<double>> sensorHistory = {};
  Timer? _timer;
  final Random _random = Random();
  double tempThreshold = 30.0;
  double humidityThreshold = 80.0;
  double windThreshold = 50.0;
  double rainThreshold = 100.0;
  String username = '';

  Map<int, String> districts = {1: 'Quận 1', 2: 'Quận 2'};

  @override
  void initState() {
    super.initState();
    selectedArea = widget.areaId;
    _loadUserData();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadDistricts();

    // Khởi tạo sensor history
    sensorHistory['temperature'] = List.generate(
      8,
      (index) => 20 + _random.nextDouble() * 15,
    );
    sensorHistory['humidity'] = List.generate(
      8,
      (index) => 40 + _random.nextDouble() * 40,
    );
    sensorHistory['windSpeed'] = List.generate(
      8,
      (index) => _random.nextDouble() * 20,
    );
    sensorHistory['rainLevel'] = List.generate(
      8,
      (index) => _random.nextDouble() * 10,
    );

    _listenToSensorData();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateSensorData();
    });
  }

  void _listenToSensorData() {
    // Lắng nghe dữ liệu cho tất cả quận
    for (int i = 1; i <= districts.length; i++) {
      final districtName = districts[i];
      if (districtName != null && areaData[i] != null) {
        FirebaseService.listenToSensorDataForDistrict(i, districtName, (data) {
          setState(() {
            areaData[i]!.temperature = data['temperature'];
            areaData[i]!.humidity = data['humidity'];
            areaData[i]!.windSpeed = data['windSpeed'];
            areaData[i]!.rainLevel = data['rainLevel'];
            areaData[i]!.switchStatus = data['switchStatus'];
          });
        });
      }
    }
  }

  Future<void> _updateSwitchStatus(int area, bool status) async {
    await FirebaseService.updateSwitchStatus(area, status);
  }

  _loadUserData() async {
    String user = await StorageService.getUsername();
    setState(() {
      username = user;
    });
  }

  Future<void> _loadDistricts() async {
    final savedDistricts = await StorageService.getDistricts();
    setState(() {
      districts = {};
      for (int i = 0; i < savedDistricts.length; i++) {
        districts[i + 1] = savedDistricts[i];
      }

      // Khởi tạo lại areaData cho tất cả quận
      areaData.clear();
      for (int i = 1; i <= districts.length; i++) {
        areaData[i] = SensorData();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateSensorData() {
    final currentData = areaData[selectedArea];
    if (currentData != null) {
      setState(() {
        sensorHistory['temperature']?.removeAt(0);
        sensorHistory['temperature']?.add(currentData.temperature);

        sensorHistory['humidity']?.removeAt(0);
        sensorHistory['humidity']?.add(currentData.humidity);

        sensorHistory['windSpeed']?.removeAt(0);
        sensorHistory['windSpeed']?.add(currentData.windSpeed);

        sensorHistory['rainLevel']?.removeAt(0);
        sensorHistory['rainLevel']?.add(currentData.rainLevel);
      });
    }
  }

  void _logout() async {
    await StorageService.logout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Người dùng',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade700),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getSensorTitle() {
    switch (selectedSensor) {
      case 'temperature':
        return 'Nhiệt độ';
      case 'humidity':
        return 'Độ ẩm';
      case 'windSpeed':
        return 'Tốc độ gió';
      case 'rainLevel':
        return 'Lượng mưa';
      default:
        return 'Cảm biến theo thời gian';
    }
  }

  String _getSensorUnit() {
    switch (selectedSensor) {
      case 'temperature':
        return '°C';
      case 'humidity':
        return '%';
      case 'windSpeed':
        return 'm/s';
      case 'rainLevel':
        return 'mm';
      default:
        return '';
    }
  }

  Color _getSensorColor() {
    switch (selectedSensor) {
      case 'temperature':
        return Colors.orange;
      case 'humidity':
        return Colors.blue;
      case 'windSpeed':
        return Colors.green;
      case 'rainLevel':
        return Colors.indigo;
      default:
        return Colors.white;
    }
  }

  Widget _buildChart() {
    final data = sensorHistory[selectedSensor];
    if (data == null || data.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 200,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getSensorTitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getSensorUnit(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Text(
                '${data.last.toStringAsFixed(1)}${_getSensorUnit()}',
                style: TextStyle(
                  color: _getSensorColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              size: Size(double.infinity, 120),
              painter: ChartPainter(data, _getSensorColor(), _getSensorUnit()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard(
    double temperature,
    bool switchStatus,
    Function(bool) onSwitchChanged,
  ) {
    Color lightColor;

    if (switchStatus == false) {
      lightColor = Colors.grey;
    } else {
      if (temperature > tempThreshold && switchStatus == true) {
        lightColor = Colors.red;
      } else {
        lightColor = Colors.green;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.power_settings_new,
            color: switchStatus ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          const Text(
            'Điều khiển',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Switch(
            value: switchStatus,
            onChanged: onSwitchChanged,
            activeThumbColor: Colors.green,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 12),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lightColor,
              boxShadow: [
                BoxShadow(
                  color: lightColor.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.lightbulb, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    String title,
    double value,
    String unit,
    IconData icon,
    Color color,
    String sensorType,
  ) {
    bool isWarning = false;
    bool isSelected = selectedSensor == sensorType;

    if (title == 'Nhiệt độ' && (value > tempThreshold || value < 10))
      isWarning = true;
    if (title == 'Độ ẩm' &&
        (value > humidityThreshold || value < humidityThreshold))
      isWarning = true;
    if (title == 'Tốc độ gió' && value > windThreshold) isWarning = true;
    if (title == 'Mưa' && value > rainThreshold) isWarning = true;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSensor = sensorType;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: isWarning
              ? Border.all(color: Colors.red, width: 1)
              : isSelected
              ? Border.all(color: color, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : (isWarning ? Colors.red : color),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${value.toStringAsFixed(1)}$unit',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWarning)
                  const Icon(Icons.warning, color: Colors.red, size: 12),
                if (isWarning) const SizedBox(width: 4),
                Text(
                  '${value.toStringAsFixed(0)}$unit',
                  style: TextStyle(
                    color: isSelected
                        ? color
                        : (isWarning ? Colors.red : Colors.white),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentData = areaData[selectedArea];
    if (currentData == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(districts[selectedArea] ?? 'Sensor Station'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: _showUserMenu,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    tempThreshold: tempThreshold,
                    humidityThreshold: humidityThreshold,
                    windThreshold: windThreshold,
                    rainThreshold: rainThreshold,
                    onTempThresholdChanged: (value) {
                      setState(() => tempThreshold = value);
                    },
                    onHumidityThresholdChanged: (value) {
                      setState(() => humidityThreshold = value);
                    },
                    onWindThresholdChanged: (value) {
                      setState(() => windThreshold = value);
                    },
                    onRainThresholdChanged: (value) {
                      setState(() => rainThreshold = value);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey.shade900,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey.shade800),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sensors, color: Colors.white, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Sensor Station',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white, size: 18),
              title: const Text(
                'Trang chủ',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SensorStationScreen(),
                  ),
                );
              },
            ),
            for (final entry in districts.entries)
              ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 18,
                ),
                title: Text(
                  entry.value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                selected: selectedArea == entry.key,
                selectedTileColor: Colors.grey.shade700,
                onTap: () {
                  setState(() {
                    selectedArea = entry.key;
                  });
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildChart(),
          const SizedBox(height: 12),

          _buildControlCard(currentData.temperature, currentData.switchStatus, (
            value,
          ) {
            setState(() {
              currentData.switchStatus = value;
            });
            _updateSwitchStatus(selectedArea, value);
          }),
          const SizedBox(height: 12),

          Expanded(
            child: Column(
              children: [
                _buildSensorCard(
                  'Nhiệt độ',
                  currentData.temperature,
                  '°C',
                  Icons.thermostat,
                  Colors.orange,
                  'temperature',
                ),
                const SizedBox(height: 12),
                _buildSensorCard(
                  'Độ ẩm',
                  currentData.humidity,
                  '%',
                  Icons.water_drop,
                  Colors.blue,
                  'humidity',
                ),
                const SizedBox(height: 12),
                _buildSensorCard(
                  'Tốc độ gió',
                  currentData.windSpeed,
                  'm/s',
                  Icons.air,
                  Colors.green,
                  'windSpeed',
                ),
                const SizedBox(height: 12),
                _buildSensorCard(
                  'Mưa',
                  currentData.rainLevel,
                  'mm',
                  Icons.grain,
                  Colors.indigo,
                  'rainLevel',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
