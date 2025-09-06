class SensorEntity {
	final int id;
	final String sensorType;
	const SensorEntity({required this.id, required this.sensorType});
}

class ActuatorEntity {
	final int id;
	final String actuatorName;
	final String type;
	final String pinNumber;
	final String status; // on/off
	final String? mode; // manual/auto (nullable if not provided)
	const ActuatorEntity({
		required this.id,
		required this.actuatorName,
		required this.type,
		required this.pinNumber,
		required this.status,
		this.mode,
	});

	bool get isOn => status.toLowerCase() == 'on';
	bool get isAuto => (mode ?? '').toLowerCase() == 'auto';
}

class PlantRuleEntity {
	final int id;
	final String plantName;
	final int minMoisture;
	final int maxMoisture;
	final int preferredTemp;
	final int preferredHumidity;
	const PlantRuleEntity({
		required this.id,
		required this.plantName,
		required this.minMoisture,
		required this.maxMoisture,
		required this.preferredTemp,
		required this.preferredHumidity,
	});
}

class PlantEntity {
	final int id;
	final int deviceId;
	final int irrigationRuleId;
	final String plantName;
	final String imageUrl;
	final PlantRuleEntity rule;
	const PlantEntity({
		required this.id,
		required this.deviceId,
		required this.irrigationRuleId,
		required this.plantName,
		required this.imageUrl,
		required this.rule,
	});
}

class DetailDeviceEntity {
	final int id;
	final String deviceName;
	final String deviceCode;
	final String status;
	final List<SensorEntity> sensors;
	final List<ActuatorEntity> actuators;
	const DetailDeviceEntity({
		required this.id,
		required this.deviceName,
		required this.deviceCode,
		required this.status,
		required this.sensors,
		required this.actuators,
	});

	bool get isOnline => status.toLowerCase() == 'online';
}
