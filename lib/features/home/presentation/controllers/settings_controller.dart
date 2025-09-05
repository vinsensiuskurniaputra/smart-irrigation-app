import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_irrigation_app/service_locator.dart';

class SettingsController extends GetxController {
  // Your controller code here
  Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  static const String _themePreferenceKey = 'theme_mode';
  static const String _notificationPermissionKey = 'notification_permission';

  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool notificationEnabled = true.obs;
  final RxBool isLoading = true.obs; // Add loading state

  @override
  void onInit() {
    super.onInit();
    // Initialize all data before UI is shown
    _initializeData();
  }
  
  @override
  void onReady() {
    super.onReady();
    // This ensures we refresh data when the page is displayed
    refreshProfileData();
  }

  // Initialize all data asynchronously
  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      
      // Load all preferences in parallel
      await Future.wait([
        loadThemeMode(),
        loadNotificationPermission(),
        fetchProfileData(),
      ]);
      
    } catch (e) {
      errorMessage.value = 'Failed to load settings: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Add this method to force refresh when needed
  Future<void> refreshProfileData() async {
    await Future.wait([
      fetchProfileData(),
      loadNotificationPermission(),
    ]);
  }

  // Method to wait for initialization to complete
  Future<void> waitForInitialization() async {
    while (isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  // Method to force complete refresh of all settings
  Future<void> forceRefresh() async {
    await _initializeData();
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  // Load saved theme mode from SharedPreferences
  Future<void> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString(_themePreferenceKey);
      
      if (savedThemeMode != null) {
        if (savedThemeMode == 'dark') {
          themeMode.value = ThemeMode.dark;
          // Only change theme if it's not already set
          if (Get.isDarkMode != true) {
            Get.changeThemeMode(ThemeMode.dark);
          }
        } else {
          themeMode.value = ThemeMode.light;
          // Only change theme if it's not already set
          if (Get.isDarkMode != false) {
            Get.changeThemeMode(ThemeMode.light);
          }
        }
      } else {
        // Default to light mode if no preference is saved
        themeMode.value = ThemeMode.light;
      }
    } catch (e) {
      // Handle error and default to light mode
      themeMode.value = ThemeMode.light;
    }
  }

  // Toggle theme and save the preference
  Future<void> toggleTheme(bool isOn) async {
    try {
      themeMode.value = isOn ? ThemeMode.dark : ThemeMode.light;
      Get.changeThemeMode(themeMode.value);
      
      // Save theme preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, isOn ? 'dark' : 'light');
    } catch (e) {
      // Handle error but keep the UI state
      Get.snackbar(
        'Error',
        'Failed to save theme preference',
        backgroundColor: AppColors.danger,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Load saved notification permission from SharedPreferences
  Future<void> loadNotificationPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool storedPermission = prefs.getBool(_notificationPermissionKey) ?? true;
      
      // Also check system-level permission
      final systemPermission = await Permission.notification.status;
      
      // If system permission is denied but app setting is enabled, update app setting
      if (systemPermission.isDenied && storedPermission) {
        storedPermission = false;
        await prefs.setBool(_notificationPermissionKey, false);
      }
      
      notificationEnabled.value = storedPermission;
    } catch (e) {
      // Handle error and default to true
      notificationEnabled.value = true;
    }
  }


  Future<void> logout() async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Perform logout operations
      final prefs = await SharedPreferences.getInstance();
      
      // Save the current theme mode value before clearing preferences
      final savedThemeMode = prefs.getString(_themePreferenceKey);

      // await sl<LogoutUsecase>().call();
      
      // Clear all stored user data except theme
      await prefs.clear();
      
      // Restore theme preference after logout
      if (savedThemeMode != null) {
        await prefs.setString(_themePreferenceKey, savedThemeMode);
      }

      // Dismiss loading dialog
      Get.back();

      // Navigate to login page
      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Success',
        'You have been logged out successfully',
        backgroundColor: AppColors.primary.withOpacity(0.7),
        colorText: AppColors.white,
      );

      // Before navigating away, clear our own data
      name.value = '';
      email.value = '';
      profileImageUrl.value = '';
    } catch (e) {
      // Dismiss loading dialog if error
      Get.back();

      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        backgroundColor: AppColors.danger,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> fetchProfileData() async {
    try {
      // Always get a fresh instance of SharedPreferences instead of using sl<SharedPreferences>()
      // This ensures we always get the latest data
      final prefs = await SharedPreferences.getInstance();
      
      // Clear previous data first to ensure we don't show stale data
      name.value = '';
      email.value = '';
      profileImageUrl.value = '';
      
      // Get user name and email
      name.value = prefs.getString('name') ?? '-';
      email.value = prefs.getString('email') ?? '-';
      
      // Get profile image URL
      final photoUrl = prefs.getString('photo_profile');
      if (photoUrl != null && photoUrl.isNotEmpty) {
        profileImageUrl.value = photoUrl;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat nama pengguna';
    }
  }
}