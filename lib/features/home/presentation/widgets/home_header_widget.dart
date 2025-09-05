import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/routes.dart';

class HomeHeaderWidget extends StatelessWidget {
  final String userName;
  final String greeting;
  final String mainQuestion;

  const HomeHeaderWidget({
    super.key,
    this.userName = 'Farhan',
    this.greeting = 'Good Morning',
    this.mainQuestion = 'How\'s Your Day?',
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.darkSurface : AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkTheme 
                ? AppColors.charcoal.withOpacity(0.3)
                : AppColors.gray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting text
                  Text(
                    '$greeting, $userName',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: isDarkTheme 
                          ? AppColors.darkTextSecondary 
                          : AppColors.gray,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Main question text
                  Text(
                    mainQuestion,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme 
                          ? AppColors.darkText 
                          : AppColors.primary,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right side icon
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.settings);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkTheme 
                      ? AppColors.darkCard 
                      : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkTheme 
                        ? AppColors.darkDivider 
                        : AppColors.platinum,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.settings,
                  size: 28,
                  color: isDarkTheme 
                      ? AppColors.silver 
                      : AppColors.slate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
