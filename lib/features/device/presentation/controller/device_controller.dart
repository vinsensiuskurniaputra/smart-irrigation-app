import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/features/device/domain/entities/detail_device_entity.dart';
import 'package:smart_irrigation_app/features/device/domain/usecases/get_detail_device.dart';
import 'package:smart_irrigation_app/features/device/data/services/device_websocket_service.dart';
import 'package:smart_irrigation_app/features/device/data/models/live_sensor_model.dart';
import 'package:smart_irrigation_app/service_locator.dart';

enum DevicePageStatus { initial, loading, success, error }
enum ChartStatus { initial, loading, success, noData, error }

class DeviceController extends GetxController with GetSingleTickerProviderStateMixin {
  // Reactive state
  final device = Rxn<DetailDeviceEntity>();
  final plants = <PlantEntity>[].obs;
  final selectedPlant = Rxn<PlantEntity>();
  final status = DevicePageStatus.initial.obs;
  final chartStatus = ChartStatus.initial.obs;
  final error = RxnString();

  final actuatorStatus = <int, bool>{}.obs; // actuatorId -> on/off
  final actuatorMode = <int, String>{}.obs; // actuatorId -> manual/auto
  final currentTab = 0.obs;

  late TabController tabController;
  StreamSubscription<LiveDataModel>? _websocketSubscription;
  final isWebSocketConnected = false.obs;

  final sensorValues = <String, double>{
    'soil_moisture': 0.0,
    'temperature': 0.0,
    'humidity': 0.0,
  }.obs;

  final sensorHistory = <String, List<double>>{

  }.obs;

  final sensorTimestamps = <String, List<String>>{

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
      
      // Initialize sensor history with empty lists
      _initializeSensorHistory();
      
      // Connect to WebSocket for live data (optional - app works without it)
      _connectWebSocket(deviceId);
      
      status(DevicePageStatus.success);
    } catch (e) {
      error(e.toString());
      status(DevicePageStatus.error);
      
      // Still try to connect WebSocket even if main load fails
      try {
        _connectWebSocket(deviceId);
      } catch (wsError) {
        print('WebSocket connection failed during error recovery: $wsError');
      }
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
    _disconnectWebSocket();
    tabController.dispose();
    super.onClose();
  }

  void _initializeSensorHistory() {
    // Initialize with empty data to properly show "No data" state
    // Data will be populated when WebSocket connection is established
    sensorHistory['soil_moisture'] = <double>[];
    sensorHistory['temperature'] = <double>[];
    sensorHistory['humidity'] = <double>[];
    
    // Initialize with empty timestamps
    sensorTimestamps['soil_moisture'] = <String>[];
    sensorTimestamps['temperature'] = <String>[];
    sensorTimestamps['humidity'] = <String>[];
  }

  void _connectWebSocket(int deviceId) {
    try {
      print('Starting WebSocket connection for device $deviceId');
      _websocketSubscription = sl<DeviceWebSocketService>()
          .connectToDeviceLive(deviceId)
          .listen(
        (liveData) {
          print('Received live data: ${liveData.sensors.length} sensors');
          for (final sensor in liveData.sensors) {
            print('Sensor ${sensor.type}: ${sensor.readings.length} readings');
            if (sensor.readings.isNotEmpty) {
              print('Latest value: ${sensor.readings.last.value}');
              print('Latest timestamp: ${sensor.readings.last.recordedAt}');
            }
          }
          _handleLiveData(liveData);
          isWebSocketConnected(true);
        },
        onError: (error) {
          print('WebSocket error in controller: $error');
          isWebSocketConnected(false);
          
          // Optional: Implement retry logic
          Future.delayed(const Duration(seconds: 5), () {
            if (!isWebSocketConnected.value) {
              print('Retrying WebSocket connection...');
              _connectWebSocket(deviceId);
            }
          });
        },
        onDone: () {
          print('WebSocket connection closed');
          isWebSocketConnected(false);
        },
      );
    } catch (e) {
      print('Failed to start WebSocket connection: $e');
      isWebSocketConnected(false);
    }
  }

  void _disconnectWebSocket() {
    _websocketSubscription?.cancel();
    _websocketSubscription = null;
    sl<DeviceWebSocketService>().disconnect();
    isWebSocketConnected(false);
  }

  // Public method to manually retry WebSocket connection
  void retryWebSocketConnection() {
    final deviceId = device.value?.id;
    if (deviceId != null) {
      _disconnectWebSocket();
      _connectWebSocket(deviceId);
    }
  }

  void _handleLiveData(LiveDataModel liveData) {
    print('Processing live data for ${liveData.sensors.length} sensors');
    
    bool hasAnyData = false;
    
    for (final sensor in liveData.sensors) {
      if (sensor.readings.isNotEmpty) {
        // Get all readings from WebSocket (BE sends 10 latest values)
        // Filter out any invalid readings (NaN, infinity, etc.)
        final validReadings = sensor.readings.where((r) => 
          r.value.isFinite && !r.value.isNaN).toList();
        
        if (validReadings.isNotEmpty) {
          final readings = validReadings.map((r) => r.value).toList();
          final timestamps = validReadings.map((r) => _formatTimestamp(r.recordedAt)).toList();
          
          print('Sensor ${sensor.type}: ${readings.length} valid readings, latest: ${readings.last}');
          
          // Update current sensor values with the latest reading
          final latestReading = validReadings.last;
          sensorValues[sensor.type] = latestReading.value;
          
          // Update sensor history with all readings from WebSocket
          sensorHistory[sensor.type] = List<double>.from(readings);
          sensorTimestamps[sensor.type] = List<String>.from(timestamps);
          
          hasAnyData = true;
          print('Updated ${sensor.type} history: ${readings.length} points');
        } else {
          print('Sensor ${sensor.type}: all readings are null/invalid');
          _handleEmptySensorData(sensor.type);
        }
      } else {
        print('Sensor ${sensor.type}: empty readings array');
        _handleEmptySensorData(sensor.type);
      }
    }
    
    // Update chart status based on data availability
    if (hasAnyData) {
      chartStatus(ChartStatus.success);
    } else {
      chartStatus(ChartStatus.noData);
    }
    
    print('Live data processing complete');
  }

  void _handleEmptySensorData(String sensorType) {
    // Handle empty readings - keep existing value or set default
    if (!sensorValues.containsKey(sensorType)) {
      sensorValues[sensorType] = 0.0;
    }
    // Keep existing history if readings are empty
    if (!sensorHistory.containsKey(sensorType)) {
      sensorHistory[sensorType] = <double>[];
    }
    if (!sensorTimestamps.containsKey(sensorType)) {
      sensorTimestamps[sensorType] = <String>[];
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final recordDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      
      if (recordDate == today) {
        // If today, show time (HH:mm)
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        // If not today, show date (MM/dd)
        return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print('Error formatting timestamp: $timestamp, error: $e');
      return timestamp.split('T').first; // Fallback to date part
    }
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
    if (history != null && history.isNotEmpty) {
      // Only update if we have existing history
      history.removeAt(0);
      history.add(value);
      sensorHistory[sensorType] = List<double>.from(history);
      
      // Update timestamps for manual updates
      final timestamps = sensorTimestamps[sensorType];
      if (timestamps != null && timestamps.isNotEmpty) {
        timestamps.removeAt(0);
        timestamps.add(DateTime.now().toString().substring(11, 16)); // HH:mm format
        sensorTimestamps[sensorType] = List<String>.from(timestamps);
      }
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

  // Get the latest sensor reading with timestamp
  Map<String, dynamic> getLatestSensorReading(String sensorType) {
    final value = sensorValues[sensorType] ?? 0.0;
    final timestamps = sensorTimestamps[sensorType];
    final latestTimestamp = timestamps != null && timestamps.isNotEmpty 
        ? timestamps.last 
        : 'No data';
    
    return {
      'value': value,
      'timestamp': latestTimestamp,
    };
  }

  // Check if sensor has any data available
  bool hasSensorData(String sensorType) {
    final history = sensorHistory[sensorType];
    final value = sensorValues[sensorType];
    
    // Check if we have history data or current value
    return (history != null && history.isNotEmpty && history.any((v) => v != 0.0)) ||
           (value != null && value != 0.0);
  }

  // Check if any sensors have data
  bool get hasAnySensorData {
    return hasSensorData('soil_moisture') || 
           hasSensorData('temperature') || 
           hasSensorData('humidity');
  }

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
