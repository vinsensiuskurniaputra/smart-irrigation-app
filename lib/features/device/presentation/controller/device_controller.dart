import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/features/device/domain/entities/detail_device_entity.dart';
import 'package:smart_irrigation_app/features/device/domain/usecases/get_detail_device.dart';
import 'package:smart_irrigation_app/service_locator.dart';

enum DevicePageStatus { initial, loading, success, error }

class DeviceController extends GetxController with GetSingleTickerProviderStateMixin {
  // Reactive state
  final device = Rxn<DetailDeviceEntity>();
  final plants = <PlantEntity>[].obs;
  final selectedPlant = Rxn<PlantEntity>();
  final status = DevicePageStatus.initial.obs;
  final error = RxnString();

  final actuatorStatus = <int, bool>{}.obs; // actuatorId -> on/off
  final actuatorMode = <int, String>{}.obs; // actuatorId -> manual/auto
  final currentTab = 0.obs;

  late TabController tabController;

  final sensorValues = <String, double>{
    'soil_moisture': 68,
    'temperature': 23.5,
    'humidity': 65,
  }.obs;

  final sensorHistory = <String, List<double>>{
    'soil_moisture': [65, 62, 68, 75, 72, 70, 68],
    'temperature': [24.5, 25.0, 26.2, 25.8, 24.3, 23.9, 23.5],
    'humidity': [60, 58, 65, 70, 68, 72, 65],
  }.obs;

  Future<void> load(int deviceId) async {
    status(DevicePageStatus.loading);
    try {
      final detail = await sl<GetDetailDeviceUseCase>()(deviceId);
      device(detail);
      final plantList = await sl<GetDevicePlantsUseCase>()(deviceId);
      plants.assignAll(plantList);
      if (plantList.isNotEmpty) selectedPlant(plantList.first);
      for (final a in detail.actuators) {
        actuatorStatus[a.id] = a.isOn;
        actuatorMode[a.id] = a.mode ?? 'manual';
      }
      status(DevicePageStatus.success);
    } catch (e) {
      error(e.toString());
      status(DevicePageStatus.error);
    }
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      currentTab(tabController.index);
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void toggleActuator(int actuatorId, bool newValue) {
    actuatorStatus[actuatorId] = newValue;
    final action = newValue ? 'on' : 'off';
    sl<ControlActuatorUseCase>()(actuatorId: actuatorId, action: action).then((serverState) {
      actuatorStatus[actuatorId] = serverState;
    }).catchError((e) {
      actuatorStatus[actuatorId] = !newValue; // revert
      error('Actuator update failed: $e');
    });
  }

  void updateSensorValue(String sensorType, double value) {
    sensorValues[sensorType] = value;
    final history = sensorHistory[sensorType];
    if (history != null) {
      history.removeAt(0);
      history.add(value);
      sensorHistory[sensorType] = List<double>.from(history);
    }
  }

  Future<void> detectPlant() async {
    await Future.delayed(const Duration(seconds: 2));
    if (selectedPlant.value != null) {
      final old = selectedPlant.value!;
      final newRule = PlantRuleEntity(
        id: old.rule.id,
        plantName: 'Tomato',
        minMoisture: 65,
        maxMoisture: 85,
        preferredTemp: 24,
        preferredHumidity: 75,
      );
      selectedPlant(PlantEntity(
        id: old.id,
        deviceId: old.deviceId,
        irrigationRuleId: old.irrigationRuleId,
        plantName: 'Tomato',
        imageUrl: old.imageUrl,
        rule: newRule,
      ));
    }
  }

  bool get isDeviceOnline => device.value?.isOnline ?? false;

  void changeMode(int actuatorId, String mode) {
    final previous = actuatorMode[actuatorId];
    actuatorMode[actuatorId] = mode;
    sl<ChangeActuatorModeUseCase>()(actuatorId: actuatorId, mode: mode).then((serverMode) {
      actuatorMode[actuatorId] = serverMode;
    }).catchError((e) {
      actuatorMode[actuatorId] = previous ?? actuatorMode[actuatorId] ?? 'manual';
      error('Mode change failed: $e');
    });
  }
}
