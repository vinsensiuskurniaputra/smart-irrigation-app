import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/core/utils/page_status.dart';
import 'package:smart_irrigation_app/features/auth/domain/usecases/signin_usecase.dart';
import 'package:smart_irrigation_app/routes.dart';
import 'package:smart_irrigation_app/service_locator.dart';

class SignInController extends GetxController {
  var status = PageStatus.initial.obs;
  var errorMessage = ''.obs;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Username and password cannot be empty.';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    status.value = PageStatus.loading;
    errorMessage.value = '';

    try {
      var signinResult = await sl<SigninUseCase>().call(
        username: usernameController.text,
        password: passwordController.text,
      );

      signinResult.fold(
        (error) {
          status.value = PageStatus.error;
          errorMessage.value =
              'Login Failed check your username and password';
          Get.snackbar(
            'Login Failed',
            errorMessage.value,
            backgroundColor: AppColors.danger,
            colorText: AppColors.white,
          );
        },
        (data) {
          status.value = PageStatus.success;
          Get.offAllNamed(AppRoutes.home);
        },
      );
    } catch (e) {
      errorMessage.value = "Login failed: ${e.toString()}";
    } finally {
      status.value = PageStatus.initial;
    }
  }

  void goToSignUp() {}

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
