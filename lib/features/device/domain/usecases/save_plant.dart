import 'package:smart_irrigation_app/features/device/domain/entities/save_plant_entity.dart';
import 'package:smart_irrigation_app/features/device/domain/repositories/plant_prediction_repository.dart';

class SavePlantUseCase {
  final PlantPredictionRepository _repository;

  SavePlantUseCase(this._repository);

  Future<SavePlantEntity> call(int deviceId, int labelIndex) async {
    return await _repository.savePlant(deviceId, labelIndex);
  }
}
