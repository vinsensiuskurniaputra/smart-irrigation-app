import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/features/device/domain/entities/detail_device_entity.dart';
import 'package:smart_irrigation_app/features/device/domain/usecases/get_detail_device.dart';
import 'package:smart_irrigation_app/service_locator.dart';

enum DevicePageStatus { initial, loading, success, error }

class DeviceController extends ChangeNotifier {
  DetailDeviceEntity? device;
  List<PlantEntity> plants = [];
  PlantEntity? selectedPlant;
  DevicePageStatus status = DevicePageStatus.initial;
  String? error;

  // Actuator local state
  final Map<int, bool> actuatorStatus = {}; // actuatorId -> on/off
  final Map<int, String> actuatorMode = {}; // actuatorId -> manual/auto

  // Sensor values
  final Map<String, double> sensorValues = {
    "soil_moisture": 68,
    "temperature": 23.5,
    "humidity": 65,
  };

  // Sensor data history
  final Map<String, List<double>> sensorHistory = {
    "soil_moisture": [65, 62, 68, 75, 72, 70, 68],
    "temperature": [24.5, 25.0, 26.2, 25.8, 24.3, 23.9, 23.5],
    "humidity": [60, 58, 65, 70, 68, 72, 65],
  };

  Future<void> load(int deviceId) async {
    status = DevicePageStatus.loading;
    notifyListeners();
    try {
      final detail = await sl<GetDetailDeviceUseCase>()(deviceId);
      device = detail;
      final plantList = await sl<GetDevicePlantsUseCase>()(deviceId);
      plants = plantList;
      if (plants.isNotEmpty) selectedPlant = plants.first;
      // init actuators maps
      for (final a in detail.actuators) {
        actuatorStatus[a.id] = a.isOn;
        actuatorMode[a.id] = a.mode ?? 'manual';
      }
      status = DevicePageStatus.success;
    } catch (e) {
      error = e.toString();
      status = DevicePageStatus.error;
    }
    notifyListeners();
  }

  // Toggle actuator status
  void toggleActuator(int actuatorId, bool newValue) {
    actuatorStatus[actuatorId] = newValue;
    // TODO: call actuator toggle API
    notifyListeners();
  }

  // Update sensor value (for simulation purposes)
  void updateSensorValue(String sensorType, double value) {
    sensorValues[sensorType] = value;
    
    // Add to history (in a real app, this would be time-based)
    final history = sensorHistory[sensorType];
    if (history != null) {
      history.removeAt(0);
      history.add(value);
    }
    
    notifyListeners();
  }

  // Method to detect plant using camera
  Future<void> detectPlant() async {
    // In a real app, this would open the camera and use ML to detect the plant
    print('Detecting plant...');
    
    // Simulate a delay for API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate updating selectedPlant with new rule (immutably)
    if (selectedPlant != null) {
      final old = selectedPlant!;
      final newRule = PlantRuleEntity(
        id: old.rule.id,
        plantName: 'Tomato',
        minMoisture: 65,
        maxMoisture: 85,
        preferredTemp: 24,
        preferredHumidity: 75,
      );
      selectedPlant = PlantEntity(
        id: old.id,
        deviceId: old.deviceId,
        irrigationRuleId: old.irrigationRuleId,
        plantName: 'Tomato',
        imageUrl: old.imageUrl,
        rule: newRule,
      );
    }
    notifyListeners();
  }

  // Get device status
  bool get isDeviceOnline => device?.isOnline ?? false;
}
