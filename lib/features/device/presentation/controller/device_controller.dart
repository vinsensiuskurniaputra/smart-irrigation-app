import 'package:flutter/material.dart';

class DeviceController extends ChangeNotifier {
  // Mock data
  final Map<String, dynamic> deviceData = {
    "id": 1,
    "device_name": "Greenhouse",
    "device_code": "GH-001",
    "status": "online",
    "sensors": [
      {
        "id": 1,
        "sensor_type": "soil_moisture"
      },
      {
        "id": 2,
        "sensor_type": "temperature"
      },
      {
        "id": 3,
        "sensor_type": "humidity"
      }
    ],
    "actuators": [
      {
        "id": 1,
        "actuator_name": "Water Pump",
        "type": "pump",
        "pin_number": "A1",
        "status": "off"
      },
      {
        "id": 2,
        "actuator_name": "Grow Light",
        "type": "lamp",
        "pin_number": "A2",
        "status": "off"
      }
    ]
  };

  final Map<String, dynamic> plantData = {
    "id": 1,
    "device_id": 1,
    "irrigation_rule_id": 5,
    "plant_name": "chili",
    "image_url": "",
    "rule": {
      "id": 5,
      "plant_name": "Chili",
      "min_moisture": 60,
      "max_moisture": 80,
      "preferred_temp": 17,
      "preferred_humidity": 70
    }
  };

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

  // Actuator status
  final Map<int, bool> actuatorStatus = {};

  // Constructor
  DeviceController() {
    // Initialize actuator status
    final actuators = deviceData['actuators'] as List;
    for (var actuator in actuators) {
      actuatorStatus[actuator['id']] = actuator['status'] == 'on';
    }
  }

  // Toggle actuator status
  void toggleActuator(int actuatorId, bool newValue) {
    actuatorStatus[actuatorId] = newValue;
    
    // In a real app, this would call an API
    print('Actuator $actuatorId set to ${newValue ? "on" : "off"}');
    
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
    
    // Update plant data (simulated)
    plantData['plant_name'] = 'Tomato';
    (plantData['rule'] as Map<String, dynamic>)['plant_name'] = 'Tomato';
    (plantData['rule'] as Map<String, dynamic>)['min_moisture'] = 65;
    (plantData['rule'] as Map<String, dynamic>)['max_moisture'] = 85;
    (plantData['rule'] as Map<String, dynamic>)['preferred_temp'] = 24;
    (plantData['rule'] as Map<String, dynamic>)['preferred_humidity'] = 75;
    
    notifyListeners();
  }

  // Get device status
  bool get isDeviceOnline => deviceData['status'] == 'online';
}
