import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/commons/widgets/basic_app_button.dart';
import 'package:smart_irrigation_app/commons/widgets/basic_app_text_field.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/core/utils/page_status.dart';
import 'package:smart_irrigation_app/routes.dart';
import 'package:smart_irrigation_app/features/auth/presentation/controllers/sign_up_controller.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final controller = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 35,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Text(
                  'Please enter your details correctly',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: AppColors.gray),
                ),
                SizedBox(height: 27),
                BasicAppTextField(
                  hintText: 'Name',
                  prefixIcon: Icons.abc,
                  controller: controller.name,
                ),
                SizedBox(height: 32),
                BasicAppTextField(
                  hintText: 'Username',
                  prefixIcon: Icons.person,
                  controller: controller.username,
                ),
                SizedBox(height: 32),
                BasicAppTextField(
                  hintText: 'Email',
                  prefixIcon: Icons.email,
                  controller: controller.email,
                ),
                SizedBox(height: 32),
                BasicAppTextField(
                  hintText: 'Password',
                  prefixIcon: Icons.lock,
                  controller: controller.password,
                  isPassword: true,
                ),
                SizedBox(height: 32),
                BasicAppTextField(
                  hintText: 'Confirm Password',
                  prefixIcon: Icons.lock,
                  controller: controller.confirmationPassword,
                  isPassword: true,
                ),
                SizedBox(height: 53),
                Obx(
                  () => BasicAppButton(
                      isLoading: controller.status == PageStatus.loading,
                      onPressed: () => controller.register(),
                      title: 'Create Account'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                    ),
                    TextButton(
                        onPressed: () => Get.offNamed(AppRoutes.login),
                        child: Text(
                          'Sign In',
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
