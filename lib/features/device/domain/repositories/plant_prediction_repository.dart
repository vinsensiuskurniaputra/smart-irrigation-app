import 'dart:io';
import 'package:smart_irrigation_app/features/device/domain/entities/plant_prediction_entity.dart';
import 'package:smart_irrigation_app/features/device/domain/entities/save_plant_entity.dart';

abstract class PlantPredictionRepository {
  Future<PlantPredictionEntity> predictPlant(File imageFile);
  Future<SavePlantEntity> savePlant(int deviceId, int labelIndex);
}
