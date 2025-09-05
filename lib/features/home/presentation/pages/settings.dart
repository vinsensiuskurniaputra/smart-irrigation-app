import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/home/presentation/controllers/settings_controller.dart';
import 'package:smart_irrigation_app/routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<SettingsController>(
          future: _initializeController(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }
            
            final controller = snapshot.data!;
            return _buildSettingsContent(context, controller);
          },
        ),
      ),
    );
  }

  Future<SettingsController> _initializeController() async {
    final controller = Get.put(
      SettingsController(),
      tag: DateTime.now().toString(), // Unique tag forces new instance
      permanent: false, // Not permanent so it can be garbage collected
    );
    
    // Wait for initialization to complete
    await controller.waitForInitialization();
    
    return controller;
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Loading settings...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.danger,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Refresh the page
              Get.forceAppUpdate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, SettingsController controller) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: Obx(() => controller.profileImageUrl.isEmpty
                    ? CircleAvatar(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurface
                            : AppColors.lightGray,
                        child: const Icon(Icons.person),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(controller.profileImageUrl.value),
                        onBackgroundImageError: (exception, stackTrace) {
                        // If image fails to load, fallback to default icon
                        controller.profileImageUrl.value = '';
                      },
                    )
                ),
                title: Obx(() => Text(
                  controller.name.value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                subtitle: Obx(() => Text(controller.email.value)),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Preferences',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Obx(() => SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: controller.isDarkMode,
                    onChanged: (val) {
                      controller.toggleTheme(val);
                    },
                    activeColor: AppColors.white,
                  )),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(
                      Icons.language,
                    ),
                    title: Text('Language'),
                    trailing: Text('English'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Security',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Sign out from your account'),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
                    onTap: () {
                      // Show confirmation dialog
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Logout Confirmation'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.gray),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Get.back(); // Close dialog
                                controller.logout();
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
