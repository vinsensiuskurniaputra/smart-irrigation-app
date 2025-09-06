import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/home/presentation/controllers/home_controller.dart';
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

  void _onDeviceTap(dynamic device) {
    // TODO: map entity/model for detail page
    Get.toNamed(AppRoutes.deviceDetail, arguments: device);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
  final controller = Get.put(HomeController());
    
    return Scaffold(
      backgroundColor: isDarkTheme ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchDevices();
          await controller.fetchName();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Widget (reactive for name changes)
            SliverToBoxAdapter(
              child: Obx(() => HomeHeaderWidget(
                    userName: controller.name.value,
                    greeting: _getGreetingBasedOnTime(),
                    mainQuestion: 'Ready to Irrigate?',
                  )),
            ),

            // Reactive section
            SliverToBoxAdapter(
              child: Obx(() {
                final list = controller.devices
                    .map((e) => DeviceModel(
                          id: e.id,
                          deviceName: e.deviceName,
                          deviceCode: e.deviceCode,
                          status: e.status,
                        ))
                    .toList();
                return Column(
                  children: [
                    DeviceStatsRow(devices: list),
                    DevicesListWidget(
                      devices: list,
                      onDeviceTap: (d) => _onDeviceTap(d),
                      headerTitle: 'Connected Devices',
                    ),
                  ],
                );
              }),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
}
