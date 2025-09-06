import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/core/utils/page_status.dart';
import 'package:smart_irrigation_app/features/auth/domain/usecases/signup_usecase.dart';
import 'package:smart_irrigation_app/routes.dart';
import 'package:smart_irrigation_app/service_locator.dart';

class SignUpController extends GetxController {
  var status = PageStatus.initial.obs;
  var errorMessage = ''.obs;

  TextEditingController name = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();

  TextEditingController password = TextEditingController();
  TextEditingController confirmationPassword = TextEditingController();

  void register() async {
    if (name.text.isEmpty || password.text.isEmpty || password.text.isEmpty) {
      errorMessage.value = 'All fields are required';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: AppColors.primary, colorText: AppColors.white);
      return;
    }

    if (password.text != confirmationPassword.text) {
      errorMessage.value = 'Password and confirmation password must match';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: AppColors.primary, colorText: AppColors.white);
      return;
    }

    status.value = PageStatus.loading;
    errorMessage.value = '';

    var signupResult = await sl<SignupUseCase>().call(
        username: username.text, password: password.text, name: name.text, email: email.text
    );

    signupResult.fold((error) {
      status.value = PageStatus.error;
      errorMessage.value = error;
      Get.snackbar('Register Failed', errorMessage.value,
          backgroundColor: AppColors.primary, colorText: AppColors.white);
    }, (data) {
      status.value = PageStatus.success;
      Get.snackbar('Register Successful', 'Please login to continue',
          backgroundColor: AppColors.primary, colorText: AppColors.white);
      Get.offAllNamed(AppRoutes.login);
    });
  }

  @override
  void onClose() {
    name.dispose();
    username.dispose();
    email.dispose();
    password.dispose();
    confirmationPassword.dispose();
    super.onClose();
  }
}
