import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/device/presentation/pages/plant_scanner_page.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/actuator_control_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/plant_info_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/sensor_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/sensor_data_chart.dart';
import 'package:smart_irrigation_app/features/device/presentation/controller/device_controller.dart';
import 'package:smart_irrigation_app/features/device/domain/entities/detail_device_entity.dart';

class DetailDevicePage extends StatelessWidget {
  final int deviceId;
  const DetailDevicePage({super.key, required this.deviceId});

  void _init(DeviceController c) {
    if (c.status.value == DevicePageStatus.initial) {
      c.load(deviceId);
    }
  }

  void _toggleActuator(DeviceController c, int actuatorId, bool newValue) => c.toggleActuator(actuatorId, newValue);
  void _changeActuatorMode(DeviceController c, int actuatorId, ActuatorMode newMode) => c.changeMode(actuatorId, newMode.name);

  Widget _buildBody(DeviceController ctrl, TabController tabs) {
    return Obx(() {
      final s = ctrl.status.value;
      if (s == DevicePageStatus.loading || s == DevicePageStatus.initial) {
        return const Center(child: CircularProgressIndicator());
      }
      if (s == DevicePageStatus.error) {
        return Center(child: Text(ctrl.error.value ?? 'Error'));
      }
      return TabBarView(
        controller: tabs,
        children: [
          _buildOverviewTab(ctrl),
          _buildChartsTab(ctrl),
          _buildControlsTab(ctrl),
        ],
      );
    });
  }

  void _onPredictPlant(DeviceController controller, BuildContext context) async {
    // Navigate to plant scanner page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlantScannerPage(),
      ),
    );
    
    // Handle the result from plant scanner
    if (result != null && result is Map<String, dynamic>) {
      // TODO: map result into controller.detectPlant or update selectedPlant
      if (result['plantName'] != null && controller.selectedPlant.value != null) {
        final old = controller.selectedPlant.value!;
        controller.selectedPlant(PlantEntity(
          id: old.id,
          deviceId: old.deviceId,
          irrigationRuleId: old.irrigationRuleId,
          plantName: result['plantName'],
          imageUrl: old.imageUrl,
          rule: old.rule,
        ));
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Identified plant: ${result['plantName']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeviceController(), tag: deviceId.toString());
    _init(controller);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final title = controller.device.value?.deviceName ?? 'Device';
      final currentIndex = controller.currentTab.value;
      return Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontSize: 18)),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            controller: controller.tabController,
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
        body: _buildBody(controller, controller.tabController),
        floatingActionButton: currentIndex == 2
            ? FloatingActionButton(
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
              )
            : null,
      );
    });
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
            if (ctrl.selectedPlant.value != null)
              PlantInfoCard(
                plantName: ctrl.selectedPlant.value!.plantName,
                imageUrl: ctrl.selectedPlant.value!.imageUrl,
                irrigationRules: {
                  'plant_name': ctrl.selectedPlant.value!.rule.plantName,
                  'min_moisture': ctrl.selectedPlant.value!.rule.minMoisture,
                  'max_moisture': ctrl.selectedPlant.value!.rule.maxMoisture,
                  'preferred_temp': ctrl.selectedPlant.value!.rule.preferredTemp,
                  'preferred_humidity': ctrl.selectedPlant.value!.rule.preferredHumidity,
                },
                onPredictPlant: () => _onPredictPlant(ctrl, Get.context!),
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
    final ctx = Get.context!;
    final isDarkTheme = Theme.of(ctx).brightness == Brightness.dark;
    final actuators = ctrl.device.value?.actuators ?? [];
    
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
        onToggle: (value) => _toggleActuator(ctrl, actuator.id, value),
        mode: (ctrl.actuatorMode[actuator.id] ?? actuator.mode ?? 'manual') == 'auto'
          ? ActuatorMode.auto
          : ActuatorMode.manual,
        onModeChanged: (mode) => _changeActuatorMode(ctrl, actuator.id, mode),
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
                      'Current Plant: ${ctrl.selectedPlant.value?.rule.plantName ?? '-'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? AppColors.darkText : AppColors.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Soil Moisture: ${ctrl.selectedPlant.value?.rule.minMoisture ?? '-'}% - ${ctrl.selectedPlant.value?.rule.maxMoisture ?? '-'}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Preferred Temperature: ${ctrl.selectedPlant.value?.rule.preferredTemp ?? '-'}°C',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Preferred Humidity: ${ctrl.selectedPlant.value?.rule.preferredHumidity ?? '-'}%',
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