import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/device/presentation/pages/plant_scanner_page.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/actuator_control_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/plant_info_card.dart';
import 'package:smart_irrigation_app/features/device/presentation/widget/sensor_card.dart';
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
    // Navigate to plant scanner page with device ID
    final result = await Get.to(
      () => const PlantScannerPage(),
      arguments: {'deviceId': controller.device.value?.id},
    );
    
    // Handle the result from plant scanner
    if (result != null && result is Map<String, dynamic>) {
      if (result['success'] == true && result['plant'] != null) {
        // Successfully saved plant, refresh device data
        if (controller.device.value?.id != null) {
          try {
            // Show loading while refreshing
            Get.dialog(
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Get.theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Refreshing device data...',
                        style: TextStyle(
                          color: Get.theme.colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              barrierDismissible: false,
            );
            
            await controller.load(controller.device.value!.id);
            
            // Close loading dialog
            Get.back();
            
            final plant = result['plant'];
            Get.snackbar(
              'Plant Saved Successfully!',
              'Added ${plant.plantName} to your device with irrigation settings',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.primary,
              colorText: Get.theme.colorScheme.onPrimary,
              duration: const Duration(seconds: 4),
              icon: Icon(
                Icons.eco,
                color: Get.theme.colorScheme.onPrimary,
              ),
            );
          } catch (e) {
            // Close loading dialog if still open
            if (Get.isDialogOpen == true) {
              Get.back();
            }
            
            // Show error but still show success for plant save
            Get.snackbar(
              'Plant Saved',
              'Plant saved successfully, but couldn\'t refresh device data. Please refresh manually.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.primary,
              colorText: Get.theme.colorScheme.onPrimary,
              duration: const Duration(seconds: 4),
            );
          }
        } else {
          // No device ID available, just show success
          final plant = result['plant'];
          Get.snackbar(
            'Plant Saved Successfully!',
            'Added ${plant.plantName} to your device',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
            duration: const Duration(seconds: 3),
            icon: Icon(
              Icons.eco,
              color: Get.theme.colorScheme.onPrimary,
            ),
          );
        }
      } else if (result['plantName'] != null && controller.selectedPlant.value != null) {
        // Handle old flow (if needed for backward compatibility)
        final old = controller.selectedPlant.value!;
        controller.selectedPlant(PlantEntity(
          id: old.id,
          deviceId: old.deviceId,
          irrigationRuleId: old.irrigationRuleId,
          plantName: result['plantName'],
          imageUrl: old.imageUrl,
          rule: old.rule,
        ));
        
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
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeviceController(), tag: deviceId.toString());
    _init(controller);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final title = controller.device.value?.deviceName ?? 'Device';
      final currentIndex = controller.currentTab.value;
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(fontSize: 18)),
            centerTitle: true,
            elevation: 0,
            actions: [
              // WebSocket connection status indicator
              Obx(() => GestureDetector(
                onTap: () {
                  if (!controller.isWebSocketConnected.value) {
                    controller.retryWebSocketConnection();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Retrying connection...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: controller.isWebSocketConnected.value 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.isWebSocketConnected.value 
                            ? Icons.sync 
                            : Icons.sync_disabled,
                        color: controller.isWebSocketConnected.value 
                            ? Colors.green 
                            : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.isWebSocketConnected.value ? 'Sync' : 'Retry',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: controller.isWebSocketConnected.value 
                              ? Colors.green 
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
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
        ),
      );
    });
  }

  Widget _buildOverviewTab(DeviceController ctrl) {
    return Obx(() => SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check if we have sensor data
            if (!ctrl.hasAnySensorData) ...[
              // No data message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sensors_off,
                      size: 48,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Sensor Data Available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Waiting for sensor readings...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Sensor cards
              Row(
                children: [
                  Expanded(
                    child: ctrl.hasSensorData('soil_moisture')
                        ? SensorCard.soilMoisture(ctrl.sensorValues['soil_moisture'] ?? 0)
                        : _buildNoDataCard('Soil Moisture', '%'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ctrl.hasSensorData('temperature')
                        ? SensorCard.temperature(ctrl.sensorValues['temperature'] ?? 0)
                        : _buildNoDataCard('Temperature', '°C'),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Humidity card
              ctrl.hasSensorData('humidity')
                  ? SensorCard.humidity(ctrl.sensorValues['humidity'] ?? 0)
                  : _buildNoDataCard('Humidity', '%'),
              
              const SizedBox(height: 24),
            ],
            
            // Plant info (always show regardless of sensor data)
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
    ));
  }

  Widget _buildChartsTab(DeviceController ctrl) {
    return Obx(() {
      switch (ctrl.chartStatus.value) {
        case ChartStatus.initial:
        case ChartStatus.loading:
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading chart data...'),
              ],
            ),
          );
        case ChartStatus.noData:
          return Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: Colors.grey.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Chart Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No sensor readings available for chart display',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ctrl.retryWebSocketConnection(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Connection'),
                  ),
                ],
              ),
            ),
          );
        case ChartStatus.error:
          return Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chart Error',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load chart data. Please try again.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ctrl.retryWebSocketConnection(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Connection'),
                  ),
                ],
              ),
            ),
          );
        case ChartStatus.success:
          return _buildGraphSection();
      }
    });
  }

  Widget _buildGraphSection() {
    return GetX<DeviceController>(
      tag: deviceId.toString(),
      builder: (ctrl) {
        // Collect all sensor data
        final sensorTypes = ['soil_moisture', 'temperature', 'humidity'];
        final List<Color> sensorColors = [
          const Color(0xFF4A90E2), // Blue for soil moisture
          const Color(0xFFE74C3C), // Red for temperature
          const Color(0xFF2ECC71), // Green for humidity
        ];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart container
                Container(
                  height: 400,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sensor Data Chart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              drawHorizontalLine: true,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final int index = value.toInt();
                                    if (index >= 0 && 
                                        ctrl.sensorTimestamps.isNotEmpty &&
                                        ctrl.sensorTimestamps.values.first.length > index) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          ctrl.sensorTimestamps.values.first[index],
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 10,
                                  getTitlesWidget: (value, meta) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            minX: 0,
                            maxX: 9, // Show up to 10 data points
                            minY: 0,
                            maxY: 100,
                            lineBarsData: _generateLineChartData(ctrl, sensorTypes, sensorColors),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: Colors.black87,
                                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    final sensorType = sensorTypes[barSpot.barIndex];
                                    final value = barSpot.y;
                                    String unit = _getSensorUnit(sensorType);
                                    String name = _getSensorDisplayName(sensorType);
                                    
                                    return LineTooltipItem(
                                      '$name\n${value.toStringAsFixed(1)}$unit',
                                      TextStyle(
                                        color: sensorColors[barSpot.barIndex],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                              handleBuiltInTouches: true,
                              getTouchLineStart: (data, index) => 0,
                              getTouchLineEnd: (data, index) => double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Legend
                _buildLegend(sensorTypes, sensorColors, ctrl),
              ],
            ),
          ),
        );
      },
    );
  }

  List<LineChartBarData> _generateLineChartData(
    DeviceController ctrl,
    List<String> sensorTypes,
    List<Color> colors,
  ) {
    List<LineChartBarData> lineBarsData = [];

    for (int i = 0; i < sensorTypes.length; i++) {
      final sensorType = sensorTypes[i];
      final sensorData = ctrl.sensorHistory[sensorType];
      
      if (sensorData != null && sensorData.isNotEmpty) {
        List<FlSpot> spots = [];
        for (int j = 0; j < sensorData.length; j++) {
          spots.add(FlSpot(j.toDouble(), sensorData[j]));
        }

        lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: colors[i],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: colors[i],
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors[i].withOpacity(0.3),
                  colors[i].withOpacity(0.1),
                ],
              ),
            ),
          ),
        );
      }
    }

    return lineBarsData;
  }

  Widget _buildLegend(List<String> sensorTypes, List<Color> colors, DeviceController ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Values',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: sensorTypes.asMap().entries.map((entry) {
              final index = entry.key;
              final sensorType = entry.value;
              final color = colors[index];
              final currentValue = ctrl.sensorValues[sensorType] ?? 0.0;
              final unit = _getSensorUnit(sensorType);
              final name = _getSensorDisplayName(sensorType);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$name: ${currentValue.toStringAsFixed(1)}$unit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getSensorUnit(String sensorType) {
    switch (sensorType) {
      case 'soil_moisture':
      case 'humidity':
        return '%';
      case 'temperature':
        return '°C';
      default:
        return '';
    }
  }

  String _getSensorDisplayName(String sensorType) {
    switch (sensorType) {
      case 'soil_moisture':
        return 'Soil Moisture';
      case 'temperature':
        return 'Temperature';
      case 'humidity':
        return 'Humidity';
      default:
        return sensorType;
    }
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

  // Helper method to build a "No Data" card for sensors
  Widget _buildNoDataCard(String title, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sensors_off,
                size: 20,
                color: Colors.grey.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'No Data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Waiting for readings...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}