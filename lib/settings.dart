import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final double tempThreshold;
  final double humidityThreshold;
  final double windThreshold;
  final double rainThreshold;
  final Function(double) onTempThresholdChanged;
  final Function(double) onHumidityThresholdChanged;
  final Function(double) onWindThresholdChanged;
  final Function(double) onRainThresholdChanged;

  const SettingsScreen({
    super.key,
    required this.tempThreshold,
    required this.humidityThreshold,
    required this.windThreshold,
    required this.rainThreshold,
    required this.onTempThresholdChanged,
    required this.onHumidityThresholdChanged,
    required this.onWindThresholdChanged,
    required this.onRainThresholdChanged,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _tempController;
  late TextEditingController _humidityController;
  late TextEditingController _windController;
  late TextEditingController _rainController;

  @override
  void initState() {
    super.initState();
    _tempController = TextEditingController(text: widget.tempThreshold.toString());
    _humidityController = TextEditingController(text: widget.humidityThreshold.toString());
    _windController = TextEditingController(text: widget.windThreshold.toString());
    _rainController = TextEditingController(text: widget.rainThreshold.toString());
  }

  @override
  void dispose() {
    _tempController.dispose();
    _humidityController.dispose();
    _windController.dispose();
    _rainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildThresholdCard(
              title: 'Ngưỡng nhiệt độ cảnh báo',
              icon: Icons.thermostat,
              iconColor: Colors.orange,
              controller: _tempController,
              unit: '°C',
              minValue: 0,
              maxValue: 60,
              onChanged: (value) {
                double? temp = double.tryParse(value);
                if (temp != null && temp >= 0 && temp <= 60) {
                  widget.onTempThresholdChanged(temp);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildThresholdCard(
              title: 'Ngưỡng độ ẩm cảnh báo',
              icon: Icons.water_drop,
              iconColor: Colors.blue,
              controller: _humidityController,
              unit: '%',
              minValue: 0,
              maxValue: 100,
              onChanged: (value) {
                double? humidity = double.tryParse(value);
                if (humidity != null && humidity >= 0 && humidity <= 100) {
                  widget.onHumidityThresholdChanged(humidity);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildThresholdCard(
              title: 'Ngưỡng tốc độ gió cảnh báo',
              icon: Icons.air,
              iconColor: Colors.teal,
              controller: _windController,
              unit: 'km/h',
              minValue: 0,
              maxValue: 100,
              onChanged: (value) {
                double? wind = double.tryParse(value);
                if (wind != null && wind >= 0 && wind <= 100) {
                  widget.onWindThresholdChanged(wind);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildThresholdCard(
              title: 'Ngưỡng lượng mưa cảnh báo',
              icon: Icons.umbrella,
              iconColor: Colors.indigo,
              controller: _rainController,
              unit: 'mm',
              minValue: 0,
              maxValue: 500,
              onChanged: (value) {
                double? rain = double.tryParse(value);
                if (rain != null && rain >= 0 && rain <= 500) {
                  widget.onRainThresholdChanged(rain);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required String unit,
    required double minValue,
    required double maxValue,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    suffixText: unit,
                    suffixStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade600),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: iconColor),
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '(${minValue.toInt()}-${maxValue.toInt()})',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}