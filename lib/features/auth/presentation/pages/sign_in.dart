import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/commons/widgets/basic_app_button.dart';
import 'package:smart_irrigation_app/commons/widgets/basic_app_text_field.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/core/utils/page_status.dart';
import 'package:smart_irrigation_app/features/auth/presentation/controllers/sign_in_controller.dart';
import 'package:smart_irrigation_app/routes.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 35,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Silahkan Masuk',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Text(
                  'Masuk dengan akun yang sudah terdaftar',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: AppColors.gray),
                ),
                SizedBox(height: 27),
                BasicAppTextField(
                  hintText: 'Email / No HP',
                  prefixIcon: Icons.email,
                  controller: controller.emailController,
                ),
                SizedBox(height: 32),
                BasicAppTextField(
                  hintText: 'Password',
                  prefixIcon: Icons.lock,
                  controller: controller.passwordController,
                  isPassword: true,
                ),
                SizedBox(height: 53),
                Obx(() => BasicAppButton(
                    isLoading: controller.status == PageStatus.loading,
                    onPressed: () => controller.login(),
                    title: 'Masuk')),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun?',
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                    ),
                    TextButton(
                        onPressed: () => Get.offNamed(AppRoutes.register),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
