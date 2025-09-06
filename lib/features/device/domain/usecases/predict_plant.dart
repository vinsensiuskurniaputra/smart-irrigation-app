import 'dart:io';
import 'package:smart_irrigation_app/features/device/domain/entities/plant_prediction_entity.dart';
import 'package:smart_irrigation_app/features/device/domain/repositories/plant_prediction_repository.dart';

class PredictPlantUseCase {
  final PlantPredictionRepository _repository;

  PredictPlantUseCase(this._repository);

  Future<PlantPredictionEntity> call(File imageFile) async {
    return await _repository.predictPlant(imageFile);
  }
}
