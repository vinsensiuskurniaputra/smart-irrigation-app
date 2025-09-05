import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';

class OnBoardingContent extends StatelessWidget {
  final String image, title, description;

  const OnBoardingContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Image.asset(image, height: 200, width: 200),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Text(
          description,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            color: AppColors.gray,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
      ],
    );
  }
}
