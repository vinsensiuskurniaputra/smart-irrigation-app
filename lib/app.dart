import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:smart_irrigation_app/features/auth/presentation/pages/sign_in.dart';
import 'package:smart_irrigation_app/features/auth/presentation/pages/sign_up.dart';
import 'package:smart_irrigation_app/features/device/presentation/pages/detail_device.dart';
import 'package:smart_irrigation_app/features/device/presentation/pages/plant_scanner_page.dart';
import 'package:smart_irrigation_app/features/device/presentation/pages/chat_plant.dart';
import 'package:smart_irrigation_app/features/home/presentation/pages/settings.dart';
import 'package:smart_irrigation_app/features/onboarding/presentation/pages/welcome.dart';
import 'package:smart_irrigation_app/routes.dart';
import 'package:smart_irrigation_app/features/onboarding/presentation/pages/on_boarding.dart';
import 'package:smart_irrigation_app/features/home/presentation/pages/home_page.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.onboarding, page: () => const OnBoardingPage()),
    GetPage(name: AppRoutes.welcome, page: () => const WelcomePage()),
    GetPage(name: AppRoutes.login, page: () => SignInPage()),
    GetPage(name: AppRoutes.register, page: () => SignUpPage()),
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(name: AppRoutes.deviceDetail, page: () => DetailDevicePage(deviceId: 1)),
  GetPage(name: AppRoutes.plantScanner, page: () => PlantScannerPage()),
  GetPage(name: AppRoutes.chatPlant, page: () => const ChatPlantPage()),
  GetPage(name: AppRoutes.settings, page: () => const SettingsPage()),
  ];
}
