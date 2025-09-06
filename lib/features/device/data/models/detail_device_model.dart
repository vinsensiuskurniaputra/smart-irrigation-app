import 'package:smart_irrigation_app/features/device/domain/entities/detail_device_entity.dart';

class SensorModel {
	final int id;
	final String sensorType;
	SensorModel({required this.id, required this.sensorType});
	factory SensorModel.fromJson(Map<String, dynamic> json) => SensorModel(
				id: json['id'] as int,
				sensorType: json['sensor_type'] as String,
			);
	Map<String, dynamic> toJson() => {
				'id': id,
				'sensor_type': sensorType,
			};
	SensorEntity toEntity() => SensorEntity(id: id, sensorType: sensorType);
}

class ActuatorModel {
	final int id;
	final String actuatorName;
	final String type;
	final String pinNumber;
	final String status;
	final String? mode;
	ActuatorModel({
		required this.id,
		required this.actuatorName,
		required this.type,
		required this.pinNumber,
		required this.status,
		this.mode,
	});
	factory ActuatorModel.fromJson(Map<String, dynamic> json) => ActuatorModel(
				id: json['id'] as int,
				actuatorName: json['actuator_name'] as String,
				type: json['type'] as String,
				pinNumber: json['pin_number'] as String,
				status: json['status'] as String,
				mode: json['mode'] as String?,
			);
	Map<String, dynamic> toJson() => {
				'id': id,
				'actuator_name': actuatorName,
				'type': type,
				'pin_number': pinNumber,
				'status': status,
				'mode': mode,
			};
	ActuatorEntity toEntity() => ActuatorEntity(
				id: id,
				actuatorName: actuatorName,
				type: type,
				pinNumber: pinNumber,
				status: status,
				mode: mode,
			);
}

class PlantRuleModel {
	final int id;
	final String plantName;
	final int minMoisture;
	final int maxMoisture;
	final int preferredTemp;
	final int preferredHumidity;
	PlantRuleModel({
		required this.id,
		required this.plantName,
		required this.minMoisture,
		required this.maxMoisture,
		required this.preferredTemp,
		required this.preferredHumidity,
	});
	factory PlantRuleModel.fromJson(Map<String, dynamic> json) => PlantRuleModel(
				id: json['id'] as int,
				plantName: json['plant_name'] as String,
				minMoisture: json['min_moisture'] as int,
				maxMoisture: json['max_moisture'] as int,
				preferredTemp: json['preferred_temp'] as int,
				preferredHumidity: json['preferred_humidity'] as int,
			);
	Map<String, dynamic> toJson() => {
				'id': id,
				'plant_name': plantName,
				'min_moisture': minMoisture,
				'max_moisture': maxMoisture,
				'preferred_temp': preferredTemp,
				'preferred_humidity': preferredHumidity,
			};
	PlantRuleEntity toEntity() => PlantRuleEntity(
				id: id,
				plantName: plantName,
				minMoisture: minMoisture,
				maxMoisture: maxMoisture,
				preferredTemp: preferredTemp,
				preferredHumidity: preferredHumidity,
			);
}

class PlantModel {
	final int id;
	final int deviceId;
	final int irrigationRuleId;
	final String plantName;
	final String imageUrl;
	final PlantRuleModel rule;
	PlantModel({
		required this.id,
		required this.deviceId,
		required this.irrigationRuleId,
		required this.plantName,
		required this.imageUrl,
		required this.rule,
	});
	factory PlantModel.fromJson(Map<String, dynamic> json) => PlantModel(
				id: json['id'] as int,
				deviceId: json['device_id'] as int,
				irrigationRuleId: json['irrigation_rule_id'] as int,
				plantName: json['plant_name'] as String,
				imageUrl: (json['image_url'] ?? '') as String,
				rule: PlantRuleModel.fromJson(json['rule'] as Map<String, dynamic>),
			);
	Map<String, dynamic> toJson() => {
				'id': id,
				'device_id': deviceId,
				'irrigation_rule_id': irrigationRuleId,
				'plant_name': plantName,
				'image_url': imageUrl,
				'rule': rule.toJson(),
			};
	PlantEntity toEntity() => PlantEntity(
				id: id,
				deviceId: deviceId,
				irrigationRuleId: irrigationRuleId,
				plantName: plantName,
				imageUrl: imageUrl,
				rule: rule.toEntity(),
			);
}

class DetailDeviceModel {
	final int id;
	final String deviceName;
	final String deviceCode;
	final String status;
	final List<SensorModel> sensors;
	final List<ActuatorModel> actuators;
	DetailDeviceModel({
		required this.id,
		required this.deviceName,
		required this.deviceCode,
		required this.status,
		required this.sensors,
		required this.actuators,
	});
	factory DetailDeviceModel.fromJson(Map<String, dynamic> json) => DetailDeviceModel(
				id: json['id'] as int,
				deviceName: json['device_name'] as String,
				deviceCode: json['device_code'] as String,
				status: json['status'] as String,
				sensors: (json['sensors'] as List<dynamic>)
						.whereType<Map<String, dynamic>>()
						.map(SensorModel.fromJson)
						.toList(),
				actuators: (json['actuators'] as List<dynamic>)
						.whereType<Map<String, dynamic>>()
						.map(ActuatorModel.fromJson)
						.toList(),
			);
	Map<String, dynamic> toJson() => {
				'id': id,
				'device_name': deviceName,
				'device_code': deviceCode,
				'status': status,
				'sensors': sensors.map((e) => e.toJson()).toList(),
				'actuators': actuators.map((e) => e.toJson()).toList(),
			};
	DetailDeviceEntity toEntity() => DetailDeviceEntity(
				id: id,
				deviceName: deviceName,
				deviceCode: deviceCode,
				status: status,
				sensors: sensors.map((e) => e.toEntity()).toList(),
				actuators: actuators.map((e) => e.toEntity()).toList(),
			);
}
