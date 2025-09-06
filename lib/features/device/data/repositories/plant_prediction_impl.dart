import 'dart:io';
import 'package:smart_irrigation_app/features/device/data/models/plant_prediction_model.dart';
import 'package:smart_irrigation_app/features/device/data/models/save_plant_model.dart';
import 'package:smart_irrigation_app/features/device/data/services/plant_prediction_api_service.dart';
import 'package:smart_irrigation_app/features/device/domain/entities/plant_prediction_entity.dart';
import 'package:smart_irrigation_app/features/device/domain/entities/save_plant_entity.dart';
import 'package:smart_irrigation_app/features/device/domain/repositories/plant_prediction_repository.dart';

class PlantPredictionRepositoryImpl implements PlantPredictionRepository {
  final PlantPredictionApiService _apiService;

  PlantPredictionRepositoryImpl(this._apiService);

  @override
  Future<PlantPredictionEntity> predictPlant(File imageFile) async {
    try {
      print('=== REPOSITORY PREDICT PLANT ===');
      final response = await _apiService.predictPlant(imageFile);
      print('Repository received response: ${response.data}');
      
      final model = PlantPredictionModel.fromJson(response.data);
      print('Parsed model - confidence: ${model.confidence}, labelIndex: ${model.labelIndex}, prediction: ${model.prediction}');
      
      final entity = PlantPredictionEntity(
        confidence: model.confidence,
        labelIndex: model.labelIndex,
        prediction: model.prediction,
      );
      
      print('Created entity - isConfident: ${entity.isConfident}');
      return entity;
    } catch (e) {
      print('Repository predict plant error: $e');
      throw Exception('Failed to predict plant: $e');
    }
  }

  @override
  Future<SavePlantEntity> savePlant(int deviceId, int labelIndex) async {
    try {
      print('=== REPOSITORY SAVE PLANT ===');
      print('Repository calling API with deviceId: $deviceId, labelIndex: $labelIndex');
      
      final response = await _apiService.savePlant(deviceId, labelIndex);
      print('Repository received save response: ${response.data}');
      
      final model = SavePlantResponseModel.fromJson(response.data);
      
      return SavePlantEntity(
        id: model.data.id,
        deviceId: model.data.deviceId,
        irrigationRuleId: model.data.irrigationRuleId,
        plantName: model.data.plantName,
        imageUrl: model.data.imageUrl,
        rule: IrrigationRuleEntity(
          id: model.data.rule.id,
          plantName: model.data.rule.plantName,
          minMoisture: model.data.rule.minMoisture,
          maxMoisture: model.data.rule.maxMoisture,
          preferredTemp: model.data.rule.preferredTemp,
          preferredHumidity: model.data.rule.preferredHumidity,
        ),
      );
    } catch (e) {
      print('Repository save plant error: $e');
      throw Exception('Failed to save plant: $e');
    }
  }
}
