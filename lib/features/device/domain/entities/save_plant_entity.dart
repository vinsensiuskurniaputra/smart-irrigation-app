class SavePlantEntity {
  final int id;
  final int deviceId;
  final int irrigationRuleId;
  final String plantName;
  final String imageUrl;
  final IrrigationRuleEntity rule;

  SavePlantEntity({
    required this.id,
    required this.deviceId,
    required this.irrigationRuleId,
    required this.plantName,
    required this.imageUrl,
    required this.rule,
  });
}

class IrrigationRuleEntity {
  final int id;
  final String plantName;
  final int minMoisture;
  final int maxMoisture;
  final int preferredTemp;
  final int preferredHumidity;

  IrrigationRuleEntity({
    required this.id,
    required this.plantName,
    required this.minMoisture,
    required this.maxMoisture,
    required this.preferredTemp,
    required this.preferredHumidity,
  });
}
