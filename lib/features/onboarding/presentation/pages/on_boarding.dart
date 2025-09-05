import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:smart_irrigation_app/features/onboarding/presentation/widgets/on_boarding_content.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Stack(
            children: [
              PageView.builder(
                itemCount: controller.data.length,
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemBuilder:
                    (context, index) => OnBoardingContent(
                      image: controller.data[index].image,
                      title: controller.data[index].title,
                      description: controller.data[index].description,
                    ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: controller.skipOnboarding,
                  icon: Icon(Icons.close),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () =>
                          controller.pageIndex.value != 0
                              ? TextButton(
                                onPressed: controller.previousPage,
                                child: const Text(
                                  'Before',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                              : SizedBox(height: 20, width: 78),
                    ),
                    Obx(
                      () => Row(
                        children: List.generate(
                          controller.data.length,
                          (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: 10,
                            width: index == controller.pageIndex.value ? 20 : 10,
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color:
                                  index == controller.pageIndex.value
                                      ? AppColors.primary
                                      : AppColors.primary_500,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.nextPage,
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
