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
