import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'login.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Station',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String username = prefs.getString('username') ?? '';

    await Future.delayed(const Duration(seconds: 1));

    if (isLoggedIn && username.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SensorMonitoringPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.sensors,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sensor Station',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class SensorData {
  double temperature;
  double humidity;
  double windSpeed;
  double rainLevel;
  bool switchStatus;

  SensorData({
    this.temperature = 25.0,
    this.humidity = 60.0,
    this.windSpeed = 5.0,
    this.rainLevel = 0.0,
    this.switchStatus = false,
  });
}

class SensorMonitoringPage extends StatefulWidget {
  const SensorMonitoringPage({Key? key}) : super(key: key);

  @override
  _SensorMonitoringPageState createState() => _SensorMonitoringPageState();
}

class _SensorMonitoringPageState extends State<SensorMonitoringPage> {
  int selectedArea = 1;
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

  final Map<int, String> districts = {
    1: 'Quận 1',
    2: 'Quận 2',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    for (int i = 1; i <= 2; i++) {
      areaData[i] = SensorData();
    }
    
    sensorHistory['temperature'] = List.generate(8, (index) => 20 + _random.nextDouble() * 15);
    sensorHistory['humidity'] = List.generate(8, (index) => 40 + _random.nextDouble() * 40);
    sensorHistory['windSpeed'] = List.generate(8, (index) => _random.nextDouble() * 20);
    sensorHistory['rainLevel'] = List.generate(8, (index) => _random.nextDouble() * 10);
    
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateSensorData();
    });
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateSensorData() {
    setState(() {
      for (int i = 1; i <= 2; i++) {
        double baseTemp = i == 1 ? 25.0 : 28.0;
        double baseHumidity = i == 1 ? 60.0 : 55.0;
        double baseWind = i == 1 ? 5.0 : 7.0;
        double baseRain = i == 1 ? 2.0 : 1.0;
        
        areaData[i]!.temperature = baseTemp + _random.nextDouble() * 10;
        areaData[i]!.humidity = baseHumidity + _random.nextDouble() * 25;
        areaData[i]!.windSpeed = baseWind + _random.nextDouble() * 10;
        areaData[i]!.rainLevel = baseRain + _random.nextDouble() * 5;
      }
      
      sensorHistory['temperature']!.removeAt(0);
      sensorHistory['temperature']!.add(areaData[selectedArea]!.temperature);
      
      sensorHistory['humidity']!.removeAt(0);
      sensorHistory['humidity']!.add(areaData[selectedArea]!.humidity);
      
      sensorHistory['windSpeed']!.removeAt(0);
      sensorHistory['windSpeed']!.add(areaData[selectedArea]!.windSpeed);
      
      sensorHistory['rainLevel']!.removeAt(0);
      sensorHistory['rainLevel']!.add(areaData[selectedArea]!.rainLevel);
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');
    
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
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
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
    List<double> data = sensorHistory[selectedSensor]!;
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

  Widget _buildControlCard(double temperature, bool switchStatus, Function(bool) onSwitchChanged) {
    Color lightColor;
        
    if (switchStatus == false) {
      lightColor = Colors.grey;
    }else{
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
            activeColor: Colors.green,
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
            child: const Icon(
              Icons.lightbulb,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(String title, double value, String unit, IconData icon, Color color, String sensorType) {
    bool isWarning = false;
    bool isSelected = selectedSensor == sensorType;
    
    if (title == 'Nhiệt độ' && (value > tempThreshold || value < 10)) isWarning = true;
    if (title == 'Độ ẩm' && (value > humidityThreshold || value < humidityThreshold)) isWarning = true;
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${value.toStringAsFixed(1)}$unit',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWarning)
                  const Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 12,
                  ),
                if (isWarning) const SizedBox(width: 4),
                Text(
                  '${value.toStringAsFixed(0)}$unit',
                  style: TextStyle(
                    color: isSelected ? color : (isWarning ? Colors.red : Colors.white),
                    fontSize: 16,
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
    final currentData = areaData[selectedArea]!;
    String dist = districts[selectedArea] ?? 'Unknown Area';
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
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
              ),
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
            for (int i = 1; i <= 2; i++)
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.white, size: 18),
                title: Text(
                  districts[i]!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                selected: selectedArea == i,
                selectedTileColor: Colors.grey.shade700,
                onTap: () {
                  setState(() {
                    selectedArea = i;
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
          
          _buildControlCard(
            currentData.temperature,
            currentData.switchStatus,
            (value) {
              setState(() {
                currentData.switchStatus = value;
              });
            },
          ),
          
          Expanded(
            child: Column(
              children: [
                _buildSensorCard('Nhiệt độ', currentData.temperature, '°C', Icons.thermostat, Colors.orange, 'temperature'),
                _buildSensorCard('Độ ẩm', currentData.humidity, '%', Icons.water_drop, Colors.blue, 'humidity'),
                _buildSensorCard('Tốc độ gió', currentData.windSpeed, 'm/s', Icons.air, Colors.green, 'windSpeed'),
                _buildSensorCard('Mưa', currentData.rainLevel, 'mm', Icons.grain, Colors.indigo, 'rainLevel'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final String unit;

  ChartPainter(this.data, this.lineColor, this.unit);

  @override
  void paint(Canvas canvas, Size size) {
    double minVal = data.reduce(min);
    double maxVal = data.reduce(max);
    double range = maxVal - minVal;
    if (range == 0) range = 1;

    final chartArea = Rect.fromLTRB(30, 10, size.width - 10, size.height - 20);
    
    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      double y = chartArea.top + (chartArea.height / 4) * i;
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        axisPaint,
      );
      
      double value = maxVal - (range / 4) * i;
      final textSpan = TextSpan(
        text: value.toStringAsFixed(0),
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 10,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 5));
    }

    DateTime now = DateTime.now();
    for (int i = 0; i < data.length; i += 2) {
      double x = chartArea.left + (chartArea.width / (data.length - 1)) * i;
      canvas.drawLine(
        Offset(x, chartArea.bottom),
        Offset(x, chartArea.bottom + 5),
        axisPaint,
      );
      
      DateTime timePoint = now.subtract(Duration(seconds: (data.length - 1 - i) * 3));
      String timeLabel = '${timePoint.hour.toString().padLeft(2, '0')}:${timePoint.minute.toString().padLeft(2, '0')}';
      
      final textSpan = TextSpan(
        text: timeLabel,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 8,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 12, chartArea.bottom + 6));
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withOpacity(0.3),
          lineColor.withOpacity(0.1),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(chartArea);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      double x = chartArea.left + (chartArea.width / (data.length - 1)) * i;
      double y = chartArea.bottom - ((data[i] - minVal) / range) * chartArea.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartArea.bottom);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(chartArea.right, chartArea.bottom);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      double x = chartArea.left + (chartArea.width / (data.length - 1)) * i;
      double y = chartArea.bottom - ((data[i] - minVal) / range) * chartArea.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}