import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/device/presentation/pages/plant_scanner_page.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/actuator_control_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/plant_info_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/sensor_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/sensor_data_chart.dart';

class DetailDevicePage extends StatefulWidget {
  final int deviceId;

  const DetailDevicePage({
    super.key,
    required this.deviceId,
  });

  @override
  State<DetailDevicePage> createState() => _DetailDevicePageState();
}

class _DetailDevicePageState extends State<DetailDevicePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Mock data - in a real app, this would come from a controller/API
  final _mockDevice = {
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
        "status": "off",
        "mode": "manual"
      },
      {
        "id": 2,
        "actuator_name": "Grow Light",
        "type": "lamp",
        "pin_number": "A2",
        "status": "off",
        "mode": "manual"
      }
    ]
  };

  final _mockPlantData = {
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

  // Mock sensor values
  final Map<String, double> _sensorValues = {
    "soil_moisture": 68,
    "temperature": 23.5,
    "humidity": 65,
  };

  // Mock sensor data for charts
  final Map<String, List<double>> _sensorChartData = {
    "soil_moisture": [65, 62, 68, 75, 72, 70, 68],
    "temperature": [24.5, 25.0, 26.2, 25.8, 24.3, 23.9, 23.5],
    "humidity": [60, 58, 65, 70, 68, 72, 65],
  };

  // Actuator status and mode
  final Map<int, bool> _actuatorStatus = {};
  final Map<int, ActuatorMode> _actuatorModes = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });

    // Initialize actuator status and mode
    for (var actuator in _mockDevice['actuators'] as List) {
      _actuatorStatus[actuator['id']] = actuator['status'] == 'on';
      _actuatorModes[actuator['id']] = actuator['mode'] == 'auto' ? ActuatorMode.auto : ActuatorMode.manual;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleActuator(int actuatorId, bool newValue) {
    setState(() {
      _actuatorStatus[actuatorId] = newValue;
    });

    // In a real app, you would call an API here
    print('Toggled actuator $actuatorId to ${newValue ? "on" : "off"}');
  }
  
  void _changeActuatorMode(int actuatorId, ActuatorMode newMode) {
    setState(() {
      _actuatorModes[actuatorId] = newMode;
    });
    
    // In a real app, you would call an API here
    print('Changed actuator $actuatorId mode to ${newMode.toString().split('.').last}');
  }

  void _onPredictPlant() async {
    // Navigate to plant scanner page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlantScannerPage(),
      ),
    );
    
    // Handle the result from plant scanner
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // Update plant name if returned from scanner
        if (result['plantName'] != null) {
          _mockPlantData['plant_name'] = result['plantName'];
        }
        
        // Update plant image if returned from scanner
        if (result['imageFile'] != null) {
          // In a real app, you would save this image and update URL
          // For now, we'll just show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Identified plant: ${result['plantName']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _mockDevice['device_name'].toString(),
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDarkTheme ? AppColors.silver : AppColors.primary,
          labelColor: isDarkTheme ? AppColors.darkText : AppColors.white,
          unselectedLabelColor: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Charts'),
            Tab(text: 'Controls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          _buildOverviewTab(),
          
          // Charts Tab
          _buildChartsTab(),
          
          // Controls Tab
          _buildControlsTab(),
        ],
      ),
      floatingActionButton: _selectedTabIndex == 2 ? FloatingActionButton(
        onPressed: () {
          // In a real app, you would save actuator settings here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved')),
          );
        },
        backgroundColor: isDarkTheme ? AppColors.darkSurface : AppColors.primary,
        child: Icon(
          Icons.save_outlined,
          color: isDarkTheme ? AppColors.darkText : AppColors.white,
        ),
      ) : null,
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sensor cards
            Row(
              children: [
                Expanded(
                  child: SensorCard.soilMoisture(_sensorValues['soil_moisture']!),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SensorCard.temperature(_sensorValues['temperature']!),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Humidity card
            SensorCard.humidity(_sensorValues['humidity']!),
            
            const SizedBox(height: 24),
            
            // Plant info
            PlantInfoCard(
              plantName: _mockPlantData['plant_name'].toString(),
              imageUrl: _mockPlantData['image_url'].toString(),
              irrigationRules: _mockPlantData['rule'] as Map<String, dynamic>,
              onPredictPlant: _onPredictPlant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Soil Moisture Chart
            SensorDataChart(
              title: 'Soil Moisture',
              dataPoints: _sensorChartData['soil_moisture']!,
              unit: '%',
              minValue: 50,
              maxValue: 90,
              labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            ),
            
            const SizedBox(height: 24),
            
            // Temperature Chart
            SensorDataChart(
              title: 'Temperature',
              dataPoints: _sensorChartData['temperature']!,
              unit: '°C',
              minValue: 20,
              maxValue: 30,
              labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            ),
            
            const SizedBox(height: 24),
            
            // Humidity Chart
            SensorDataChart(
              title: 'Humidity',
              dataPoints: _sensorChartData['humidity']!,
              unit: '%',
              minValue: 50,
              maxValue: 80,
              labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsTab() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final actuators = _mockDevice['actuators'] as List;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header text
            Text(
              'Control Actuators',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? AppColors.darkText : AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Toggle devices on/off to control your irrigation system',
              style: TextStyle(
                fontSize: 14,
                color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Actuator controls
            ...actuators.map((actuator) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ActuatorControlCard(
                actuatorName: actuator['actuator_name'],
                type: actuator['type'],
                pinNumber: actuator['pin_number'],
                isActive: _actuatorStatus[actuator['id']] ?? false,
                onToggle: (value) => _toggleActuator(actuator['id'], value),
                mode: _actuatorModes[actuator['id']] ?? ActuatorMode.manual,
                onModeChanged: (mode) => _changeActuatorMode(actuator['id'], mode),
              ),
            )).toList(),
            
            const SizedBox(height: 16),
            
            // Plant rules card
            Card(
              elevation: 0,
              color: isDarkTheme ? AppColors.darkSurface : AppColors.lightGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          size: 20,
                          color: isDarkTheme ? AppColors.silver : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Plant Rules',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? AppColors.darkText : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Current Plant: ${(_mockPlantData['rule'] as Map<String, dynamic>)['plant_name']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? AppColors.darkText : AppColors.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Soil Moisture: ${(_mockPlantData['rule'] as Map<String, dynamic>)['min_moisture']}% - ${(_mockPlantData['rule'] as Map<String, dynamic>)['max_moisture']}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Preferred Temperature: ${(_mockPlantData['rule'] as Map<String, dynamic>)['preferred_temp']}°C',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Preferred Humidity: ${(_mockPlantData['rule'] as Map<String, dynamic>)['preferred_humidity']}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}