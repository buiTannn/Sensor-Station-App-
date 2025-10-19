import 'package:flutter/material.dart';
import 'sensor_monitoring_screen.dart';
import 'district_management_screen.dart';
import '../services/storage_service.dart';

class SensorStationScreen extends StatefulWidget {
  const SensorStationScreen({super.key});

  @override
  State<SensorStationScreen> createState() => _SensorStationScreenState();
}

class _SensorStationScreenState extends State<SensorStationScreen> {
  List<String> districts = ['Quận 1', 'Quận 2'];
  final Map<String, Color> districtColors = {
    'Quận 1': Colors.orange,
    'Quận 2': Colors.redAccent,
    'Quận 3': Colors.green,
    'Quận 4': Colors.purple,
    'Quận 5': Colors.cyan,
  };

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    final savedDistricts = await StorageService.getDistricts();
    setState(() {
      districts = savedDistricts.isNotEmpty
          ? savedDistricts
          : ['Quận 1', 'Quận 2'];
    });
  }

  Color _getDistrictColor(String districtName) {
    return districtColors[districtName] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Sensor Station',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DistrictManagementScreen(),
                ),
              );
              _loadDistricts(); // Reload districts after returning
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Image.asset('assets/images/sensor.png', width: 120, height: 120),
              const SizedBox(height: 10),
              const Text(
                'Sensor Station',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Chọn khu vực cần giám sát',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              ...districts.asMap().entries.map((entry) {
                final index = entry.key;
                final district = entry.value;
                return _buildZoneCard(
                  context,
                  zoneName: district,
                  areaId: index + 1,
                  borderColor: _getDistrictColor(district),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneCard(
    BuildContext context, {
    required String zoneName,
    required int areaId,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SensorMonitoringPage(areaId: areaId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zoneName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.thermostat, color: Colors.orangeAccent, size: 28),
                Icon(Icons.water_drop, color: Colors.lightBlueAccent, size: 28),
                Icon(Icons.air, color: Colors.cyanAccent, size: 28),
                Icon(Icons.grain, color: Colors.indigo, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
