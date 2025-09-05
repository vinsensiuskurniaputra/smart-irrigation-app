import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';

class BasicAppTextField extends StatelessWidget {
  final IconData? prefixIcon;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  BasicAppTextField({
    super.key,
    this.prefixIcon,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final passwordVisible = false.obs; // Gunakan GetX untuk visibility state
    final hasText = false.obs;

    controller.addListener(() {
      hasText.value = controller.text.isNotEmpty;
    });

    return Obx(
      () => TextFormField(
        controller: controller,
        obscureText: isPassword ? !passwordVisible.value : false,
        cursorColor: AppColors.primary,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon:
              prefixIcon != null
                  ? Icon(
                    prefixIcon,
                    color: AppColors.gray,
                  )
                  : null,
          suffixIcon:
              isPassword
                  ? IconButton(
                    onPressed: () {
                      passwordVisible.value = !passwordVisible.value;
                    },
                    icon: Icon(
                      passwordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: hasText.value ? AppColors.primary : AppColors.gray,
                    ),
                  )
                  : null,
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.gray, fontSize: 14),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: hasText.value ? Theme.of(context).cardColor : AppColors.gray,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: hasText.value ? Theme.of(context).cardColor : AppColors.gray,
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
