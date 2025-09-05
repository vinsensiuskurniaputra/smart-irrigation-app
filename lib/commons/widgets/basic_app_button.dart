import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double? height;
  final bool? isPrimary;
  final IconData? icon;
  final Color? textColor;
  final bool isLoading;

  const BasicAppButton({
    required this.onPressed,
    required this.title,
    this.height,
    super.key,
    this.isPrimary,
    this.icon,
    this.textColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimaryValue = isPrimary ?? true;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(height ?? 50),
        backgroundColor:
            isPrimaryValue ? AppColors.primary : AppColors.background,
        side: const BorderSide(color: AppColors.primary, width: 1),
      ).copyWith(
        // Tambahkan ini
        backgroundColor: MaterialStateProperty.resolveWith<Color>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.disabled)) {
            return isPrimaryValue ? AppColors.primary : AppColors.background;
          }
          return isPrimaryValue ? AppColors.primary : AppColors.background;
        }),
      ),
      child:
          isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.0,
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color:
                          textColor ??
                          (isPrimaryValue ? Colors.white : AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          textColor ??
                          (isPrimaryValue ? Colors.white : AppColors.primary),
                    ),
                  ),
                ],
              ),
    );
  }
}
