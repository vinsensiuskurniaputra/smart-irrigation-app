import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/home/presentation/widgets/home_header_widget.dart';
import 'package:smart_irrigation_app/features/home/presentation/widgets/devices_list_widget.dart';
import 'package:smart_irrigation_app/features/home/data/models/device_model.dart';
import 'package:smart_irrigation_app/routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _getGreetingBasedOnTime() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 20) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Static device data
  List<DeviceModel> _getStaticDevices() {
    return [
      DeviceModel(
        id: 1,
        deviceName: 'Greenhouse',
        deviceCode: 'GH-001',
        status: 'online',
      ),
      DeviceModel(
        id: 2,
        deviceName: 'Irrigation Pump',
        deviceCode: 'IP-002',
        status: 'online',
      ),
      DeviceModel(
        id: 3,
        deviceName: 'Soil Sensor A',
        deviceCode: 'SS-003',
        status: 'offline',
      ),
      DeviceModel(
        id: 4,
        deviceName: 'Weather Station',
        deviceCode: 'WS-004',
        status: 'online',
      ),
      DeviceModel(
        id: 5,
        deviceName: 'Water Valve',
        deviceCode: 'WV-005',
        status: 'offline',
      ),
      DeviceModel(
        id: 6,
        deviceName: 'Temperature Sensor',
        deviceCode: 'TS-006',
        status: 'online',
      ),
    ];
  }

  void _onDeviceTap(DeviceModel device) {
    Get.toNamed(AppRoutes.deviceDetail, arguments: device);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final devices = _getStaticDevices();
    
    return Scaffold(
      backgroundColor: isDarkTheme ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header Widget
          SliverToBoxAdapter(
            child: HomeHeaderWidget(
              userName: 'Farhan',
              greeting: _getGreetingBasedOnTime(),
              mainQuestion: 'Ready to Irrigate?',
            ),
          ),
          
          // Device Stats
          SliverToBoxAdapter(
            child: DeviceStatsRow(devices: devices),
          ),
          
          // Devices List
          SliverToBoxAdapter(
            child: DevicesListWidget(
              devices: devices,
              onDeviceTap: _onDeviceTap,
              headerTitle: 'Connected Devices',
            ),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}
