import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/utils/page_status.dart';
import 'package:smart_irrigation_app/routes.dart';
import 'package:smart_irrigation_app/service_locator.dart';

class SignInController extends GetxController {
  var status = PageStatus.initial.obs;
  var errorMessage = ''.obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Email dan password tidak boleh kosong';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    status.value = PageStatus.loading;
    errorMessage.value = '';

    // var signinResult = await sl<SigninUseCase>().call(
    //     param: SigninReqParams(
    //         emailOrPhone: emailController.text,
    //         password: passwordController.text));

    // signinResult.fold((error) {
    //   status.value = PageStatus.error;
    //   errorMessage.value = 'Login gagal. Periksa kembali email dan password.';
    //   Get.snackbar('Login Gagal', errorMessage.value,
    //       backgroundColor: Colors.redAccent, colorText: Colors.white);
    // }, (data) {
    //   status.value = PageStatus.success;
    //   final localStorage = sl<LocalStorageService>();
    //   var role = localStorage.getRole() ?? 'user';
    //   if (role == 'physician') {
    //     Get.offAllNamed(AppRoutesDoctor.root);
    //   } else if (role == 'user') {
    //   }
    // });
    Get.offAllNamed(AppRoutes.home);
  }

  void goToSignUp() {}

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
