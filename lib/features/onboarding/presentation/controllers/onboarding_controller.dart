import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_irrigation_app/core/constants/on_boarding/on_boarding.dart';
import 'package:smart_irrigation_app/routes.dart';

class OnBoardingController extends GetxController {
  PageController pageController = PageController();
  var pageIndex = 0.obs;

  List<OnBoardingData> data = onBoardingData;

  void onPageChanged(int index) {
    pageIndex.value = index;
  }

  void nextPage() async{
    if (pageIndex.value == data.length - 1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('finished_onboarding', true);
      Get.offNamed(AppRoutes.welcome);
    } else {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void previousPage() {
    pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('finished_onboarding', true);
    Get.offNamed(AppRoutes.welcome);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
