import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/assets/app_images.dart';
import 'package:smart_irrigation_app/commons/widgets/basic_app_button.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 350;
    final imageHeight = screenHeight * 0.3;

    // Responsive font sizes
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final descriptionFontSize = isSmallScreen ? 12.0 : 16.0;

    // Adjust spacings based on screen size
    final smallVerticalSpacing = isSmallScreen ? 6.0 : 12.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 50,
              vertical: isSmallScreen ? 8 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: imageHeight.clamp(120.0, 200.0),
                    child: Image.asset(
                      AppImages.welcomeImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: smallVerticalSpacing),
                  Text(
                    'Welcome to AgriSense AI',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: titleFontSize),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 8),
                  Text(
                    'Membantu anda memonitoring kesehatan tanaman anda',
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: descriptionFontSize),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ],
              ),
              SizedBox(height: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BasicAppButton(
                    isPrimary: false,
                    height: isSmallScreen ? 40 : 50,
                    onPressed: () => Get.toNamed(AppRoutes.login),
                    title: 'SIGN IN',
                  ),
                  SizedBox(height: smallVerticalSpacing),
                  BasicAppButton(
                    height: isSmallScreen ? 40 : 50,
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    title: 'SIGN UP',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
