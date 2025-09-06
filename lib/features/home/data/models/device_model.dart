import 'package:smart_irrigation_app/features/home/domain/entities/device_entity.dart';

class DeviceModel {
  final int id;
  final String deviceName;
  final String deviceCode;
  final String status;

  DeviceModel({
    required this.id,
    required this.deviceName,
    required this.deviceCode,
    required this.status,
  });

  // Factory constructor for creating instance from JSON
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as int,
      deviceName: json['device_name'] as String,
      deviceCode: json['device_code'] as String,
      status: json['status'] as String,
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'device_code': deviceCode,
      'status': status,
    };
  }

  // Helper method to check if device is online
  bool get isOnline => status.toLowerCase() == 'online';

  DeviceEntity toEntity() => DeviceEntity(
        id: id,
        deviceName: deviceName,
        deviceCode: deviceCode,
        status: status,
      );

  // Copy with method for immutable updates
  DeviceModel copyWith({
    int? id,
    String? deviceName,
    String? deviceCode,
    String? status,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      deviceCode: deviceCode ?? this.deviceCode,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'DeviceModel(id: $id, deviceName: $deviceName, deviceCode: $deviceCode, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceModel &&
        other.id == id &&
        other.deviceName == deviceName &&
        other.deviceCode == deviceCode &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceName.hashCode ^
        deviceCode.hashCode ^
        status.hashCode;
  }
}