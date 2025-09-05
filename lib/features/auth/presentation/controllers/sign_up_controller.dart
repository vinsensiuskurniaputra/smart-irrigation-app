import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/utils/page_status.dart';
import 'package:smart_irrigation_app/routes.dart';
import 'package:smart_irrigation_app/service_locator.dart';

class SignUpController extends GetxController {
  var status = PageStatus.initial.obs;
  var errorMessage = ''.obs;

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();

  TextEditingController password = TextEditingController();
  TextEditingController confirmationPassword = TextEditingController();

  void register() async {
    if (name.text.isEmpty || password.text.isEmpty || password.text.isEmpty) {
      errorMessage.value = 'Data - data tidak boleh kosong';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (password.text != confirmationPassword.text) {
      errorMessage.value = 'Password dengan konfirmasi password harus sama';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    status.value = PageStatus.loading;
    errorMessage.value = '';

    // var signupResult = await sl<SignupUseCase>().call(
    //     param: SignupReqParams(
    //         name: name.text,
    //         email: email.text,
    //         phone: int.parse(phoneNumber.text),
    //         password: password.text));

    // signupResult.fold((error) {
    //   status.value = PageStatus.error;
    //   errorMessage.value = error;
    //   Get.snackbar('Register Gagal', errorMessage.value,
    //       backgroundColor: Colors.redAccent, colorText: Colors.white);
    // }, (data) {
    //   status.value = PageStatus.success;
    //   Get.offAllNamed(AppRoutes.registrationSuccess);
    // });
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    phoneNumber.dispose();
    password.dispose();
    confirmationPassword.dispose();
    super.onClose();
  }
}
