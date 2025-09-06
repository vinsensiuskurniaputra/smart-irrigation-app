class SavePlantResponseModel {
  final SavePlantDataModel data;

  SavePlantResponseModel({
    required this.data,
  });

  factory SavePlantResponseModel.fromJson(Map<String, dynamic> json) {
    return SavePlantResponseModel(
      data: SavePlantDataModel.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}

class SavePlantDataModel {
  final int id;
  final int deviceId;
  final int irrigationRuleId;
  final String plantName;
  final String imageUrl;
  final IrrigationRuleModel rule;

  SavePlantDataModel({
    required this.id,
    required this.deviceId,
    required this.irrigationRuleId,
    required this.plantName,
    required this.imageUrl,
    required this.rule,
  });

  factory SavePlantDataModel.fromJson(Map<String, dynamic> json) {
    return SavePlantDataModel(
      id: json['id'] as int,
      deviceId: json['device_id'] as int,
      irrigationRuleId: json['irrigation_rule_id'] as int,
      plantName: json['plant_name'] as String,
      imageUrl: json['image_url'] as String,
      rule: IrrigationRuleModel.fromJson(json['rule']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'irrigation_rule_id': irrigationRuleId,
      'plant_name': plantName,
      'image_url': imageUrl,
      'rule': rule.toJson(),
    };
  }
}

class IrrigationRuleModel {
  final int id;
  final String plantName;
  final int minMoisture;
  final int maxMoisture;
  final int preferredTemp;
  final int preferredHumidity;

  IrrigationRuleModel({
    required this.id,
    required this.plantName,
    required this.minMoisture,
    required this.maxMoisture,
    required this.preferredTemp,
    required this.preferredHumidity,
  });

  factory IrrigationRuleModel.fromJson(Map<String, dynamic> json) {
    return IrrigationRuleModel(
      id: json['id'] as int,
      plantName: json['plant_name'] as String,
      minMoisture: json['min_moisture'] as int,
      maxMoisture: json['max_moisture'] as int,
      preferredTemp: json['preferred_temp'] as int,
      preferredHumidity: json['preferred_humidity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant_name': plantName,
      'min_moisture': minMoisture,
      'max_moisture': maxMoisture,
      'preferred_temp': preferredTemp,
      'preferred_humidity': preferredHumidity,
    };
  }
}
