import 'package:flutter/material.dart';
import 'main.dart';

class SensorStationScreen extends StatelessWidget {
  const SensorStationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/sensor.png',
                width: 120,
                height: 120,
              ),
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
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30), 
              _buildZoneCard(
                context,
                zoneName: "Quận 1",
                areaId: 1,
                borderColor: Colors.orange,
              ),
              _buildZoneCard(
                context,
                zoneName: "Quận 2",
                areaId: 2,
                borderColor: Colors.redAccent,
              ),
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
            )
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
