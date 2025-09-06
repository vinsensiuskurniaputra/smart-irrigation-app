import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/device/presentation/pages/plant_scanner_page.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/actuator_control_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/plant_info_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/sensor_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/sensor_data_chart.dart';
import 'package:smart_irrigation_app/features/device/presentation/controller/device_controller.dart';

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
  late DeviceController controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  controller = DeviceController();
  controller.addListener(_onControllerChanged);
  controller.load(widget.deviceId);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {}); // Rebuild to reflect loading/success/error state changes
  }

  void _toggleActuator(int actuatorId, bool newValue) => controller.toggleActuator(actuatorId, newValue);
  void _changeActuatorMode(int actuatorId, ActuatorMode newMode) {
    // TODO: mode change API
    controller.actuatorMode[actuatorId] = newMode.name;
    setState(() {});
  }

  Widget _buildBody(DeviceController ctrl) {
    if (ctrl.status == DevicePageStatus.loading || ctrl.status == DevicePageStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.status == DevicePageStatus.error) {
      return Center(child: Text(ctrl.error ?? 'Error'));
    }
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(ctrl),
        _buildChartsTab(ctrl),
        _buildControlsTab(ctrl),
      ],
    );
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
  // TODO: integrate detecting plant update with controller
        
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
  final title = controller.device?.deviceName ?? 'Device';
  return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
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
      body: _buildBody(controller),
      floatingActionButton: _selectedTabIndex == 2 ? FloatingActionButton(
        onPressed: () {
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

  // _buildBody is placed above build to avoid forward reference issues
  }

  Widget _buildOverviewTab(DeviceController ctrl) {
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
                  child: SensorCard.soilMoisture(ctrl.sensorValues['soil_moisture']!),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SensorCard.temperature(ctrl.sensorValues['temperature']!),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Humidity card
            SensorCard.humidity(ctrl.sensorValues['humidity']!),
            
            const SizedBox(height: 24),
            
            // Plant info
            if (ctrl.selectedPlant != null)
              PlantInfoCard(
                plantName: ctrl.selectedPlant!.plantName,
                imageUrl: ctrl.selectedPlant!.imageUrl,
                irrigationRules: {
                  'plant_name': ctrl.selectedPlant!.rule.plantName,
                  'min_moisture': ctrl.selectedPlant!.rule.minMoisture,
                  'max_moisture': ctrl.selectedPlant!.rule.maxMoisture,
                  'preferred_temp': ctrl.selectedPlant!.rule.preferredTemp,
                  'preferred_humidity': ctrl.selectedPlant!.rule.preferredHumidity,
                },
                onPredictPlant: _onPredictPlant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsTab(DeviceController ctrl) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Soil Moisture Chart
            SensorDataChart(
              title: 'Soil Moisture',
              dataPoints: ctrl.sensorHistory['soil_moisture']!,
              unit: '%',
              minValue: 50,
              maxValue: 90,
              labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            ),
            
            const SizedBox(height: 24),
            
            // Temperature Chart
            SensorDataChart(
              title: 'Temperature',
              dataPoints: ctrl.sensorHistory['temperature']!,
              unit: '°C',
              minValue: 20,
              maxValue: 30,
              labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            ),
            
            const SizedBox(height: 24),
            
            // Humidity Chart
            SensorDataChart(
              title: 'Humidity',
              dataPoints: ctrl.sensorHistory['humidity']!,
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

  Widget _buildControlsTab(DeviceController ctrl) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final actuators = ctrl.device?.actuators ?? [];
    
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
        actuatorName: actuator.actuatorName,
        type: actuator.type,
        pinNumber: actuator.pinNumber,
        isActive: ctrl.actuatorStatus[actuator.id] ?? actuator.isOn,
        onToggle: (value) => _toggleActuator(actuator.id, value),
        mode: (ctrl.actuatorMode[actuator.id] ?? actuator.mode ?? 'manual') == 'auto'
          ? ActuatorMode.auto
          : ActuatorMode.manual,
        onModeChanged: (mode) => _changeActuatorMode(actuator.id, mode),
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
                      'Current Plant: ${ctrl.selectedPlant?.rule.plantName ?? '-'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? AppColors.darkText : AppColors.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Soil Moisture: ${ctrl.selectedPlant?.rule.minMoisture ?? '-'}% - ${ctrl.selectedPlant?.rule.maxMoisture ?? '-'}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Preferred Temperature: ${ctrl.selectedPlant?.rule.preferredTemp ?? '-'}°C',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Preferred Humidity: ${ctrl.selectedPlant?.rule.preferredHumidity ?? '-'}%',
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