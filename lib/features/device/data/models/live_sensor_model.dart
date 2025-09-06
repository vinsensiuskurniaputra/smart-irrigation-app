class SensorReadingModel {
  final double value;
  final String recordedAt;

  const SensorReadingModel({
    required this.value,
    required this.recordedAt,
  });

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) {
    return SensorReadingModel(
      value: (json['value'] as num).toDouble(),
      recordedAt: json['recorded_at'] as String,
    );
  }
}

class LiveSensorModel {
  final int sensorId;
  final String type;
  final List<SensorReadingModel> readings;

  const LiveSensorModel({
    required this.sensorId,
    required this.type,
    required this.readings,
  });

  factory LiveSensorModel.fromJson(Map<String, dynamic> json) {
    return LiveSensorModel(
      sensorId: json['sensor_id'] as int,
      type: json['type'] as String,
      readings: (json['readings'] as List<dynamic>)
          .map((e) => SensorReadingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LiveDataModel {
  final List<LiveSensorModel> sensors;
  final String timestamp;

  const LiveDataModel({
    required this.sensors,
    required this.timestamp,
  });

  factory LiveDataModel.fromJson(Map<String, dynamic> json) {
    return LiveDataModel(
      sensors: (json['sensors'] as List<dynamic>)
          .map((e) => LiveSensorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: json['ts'] as String,
    );
  }
}
