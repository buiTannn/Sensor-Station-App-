import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  static void listenToSensorData(
    Map<int, dynamic> areaData,
    Function(Map<int, dynamic>) onDataChanged,
  ) {
    for (int i = 1; i <= 2; i++) {
      _database.child('sensor_data/Quận $i').onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          onDataChanged({
            i: {
              'temperature': (data['temperature'] ?? 0.0).toDouble(),
              'humidity': (data['humidity'] ?? 0.0).toDouble(),
              'windSpeed': (data['windSpeed'] ?? 0.0).toDouble(),
              'rainLevel': (data['rainLevel'] ?? 0.0).toDouble(),
              'switchStatus': data['switchStatus'] ?? false,
            },
          });
        }
      });
    }
  }

  static void listenToSensorDataForDistrict(
    int areaId,
    String districtName,
    Function(Map<String, dynamic>) onDataChanged,
  ) {
    _database.child('sensor_data/$districtName').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        onDataChanged({
          'temperature': (data['temperature'] ?? 0.0).toDouble(),
          'humidity': (data['humidity'] ?? 0.0).toDouble(),
          'windSpeed': (data['windSpeed'] ?? 0.0).toDouble(),
          'rainLevel': (data['rainLevel'] ?? 0.0).toDouble(),
          'switchStatus': data['switchStatus'] ?? false,
        });
      }
    });
  }

  static Future<void> updateSwitchStatus(int area, bool status) async {
    try {
      await _database.child('sensor_data/Quận $area/switchStatus').set(status);
    } catch (e) {}
  }

  static Future<void> updateSensorData(
    int area,
    Map<String, dynamic> sensorData,
  ) async {
    try {
      await _database.child('sensor_data/Quận $area').update({
        'temperature': sensorData['temperature'],
        'humidity': sensorData['humidity'],
        'windSpeed': sensorData['windSpeed'],
        'rainLevel': sensorData['rainLevel'],
      });
    } catch (e) {}
  }

  static Future<void> createSensorDataForDistrict(
    String districtName,
    Map<String, dynamic> sensorData,
  ) async {
    try {
      await _database.child('sensor_data/$districtName').set(sensorData);
    } catch (e) {}
  }

  static Future<void> initializeSampleData() async {
    try {
      // Tạo dữ liệu mẫu cho Quận 1
      await _database.child('sensor_data/Quận 1').set({
        'temperature': 25.5,
        'humidity': 60.0,
        'windSpeed': 5.2,
        'rainLevel': 0.0,
        'switchStatus': false,
      });

      // Tạo dữ liệu mẫu cho Quận 2
      await _database.child('sensor_data/Quận 2').set({
        'temperature': 26.1,
        'humidity': 65.0,
        'windSpeed': 4.8,
        'rainLevel': 0.0,
        'switchStatus': true,
      });
    } catch (e) {}
  }

  static Future<List<String>> getAllDistricts() async {
    try {
      final snapshot = await _database.child('sensor_data').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.keys.cast<String>().toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
