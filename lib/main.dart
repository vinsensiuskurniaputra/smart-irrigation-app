import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_irrigation_app/core/config/theme/app_theme.dart';
import 'package:smart_irrigation_app/core/services/connectivity_service.dart';
import 'package:smart_irrigation_app/routes.dart';
import 'package:smart_irrigation_app/service_locator.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/app.dart' as routes;
import 'package:smart_irrigation_app/features/home/presentation/controllers/settings_controller.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await _initializeApp();
  
  final String initialRoute = await _determineInitialRoute();
  
  // FlutterNativeSplash.remove();
  runApp(MyApp(initialRoute: initialRoute));
}

Future<void> _initializeApp() async {
  // Lock orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  setupServiceLocator(prefs);
  await sl.getAsync<ConnectivityService>();
  
  // Initialize theme
  final settingsController = Get.put(SettingsController());
  await settingsController.loadThemeMode();
}

Future<String> _determineInitialRoute() async {
  String initialRoute = AppRoutes.onboarding;
  
  // try {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //   final isFinishedOnboarding = prefs.getBool('finished_onboarding') ?? false;
    
  //   if (token != null && token.isNotEmpty) {
  //     initialRoute = AppRoutes.home;
  //   } else if (isFinishedOnboarding) {
  //     initialRoute = AppRoutes.login;
  //   }
  // } catch (e) {
  //   debugPrint('Token check error: $e');
  // }
  
  return initialRoute;
}
class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MYTekna',
      theme: AppTheme.mainTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: routes.AppPages.pages,
    );
  }
}