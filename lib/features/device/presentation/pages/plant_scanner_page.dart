import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/device/presentation/controller/plant_scanner_controller.dart';

class PlantScannerPage extends StatelessWidget {
  const PlantScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlantScannerController());
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkTheme ? AppColors.darkBackground : AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(isDarkTheme),
            Expanded(
              child: Obx(() => controller.isInitialized.value 
                ? _buildContent(controller, isDarkTheme) 
                : _buildLoadingIndicator(controller, isDarkTheme)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDarkTheme ? AppColors.darkText : AppColors.primary,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Text(
              'Plant Scanner',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkTheme ? AppColors.darkText : AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildContent(PlantScannerController controller, bool isDarkTheme) {
    return Obx(() {
      if (controller.isCaptured.value && controller.capturedImage != null) {
        return _buildImagePreviewScreen(controller, isDarkTheme);
      } else {
        return _buildCameraPreviewScreen(controller, isDarkTheme);
      }
    });
  }

  Widget _buildCameraPreviewScreen(PlantScannerController controller, bool isDarkTheme) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Camera Preview
              Container(
                width: double.infinity,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CameraPreview(controller.cameraController!),
                ),
              ),
              
              // Overlay frame for plant scanning - Made taller and more minimalist
              Center(
                child: Container(
                  width: MediaQuery.of(Get.context!).size.width * 0.85,
                  height: MediaQuery.of(Get.context!).size.height * 0.5, // Increased height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Simple corner indicators
                      ...List.generate(4, (index) {
                        return Positioned(
                          left: index % 2 == 0 ? 10 : null,
                          right: index % 2 == 1 ? 10 : null,
                          top: index < 2 ? 10 : null,
                          bottom: index >= 2 ? 10 : null,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                top: index < 2 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                                bottom: index >= 2 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                                left: index % 2 == 0 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                                right: index % 2 == 1 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                              ),
                            ),
                          ),
                        );
                      }),
                      
                      // Center text
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Position plant in center',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Bottom capture area - Simplified
        Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Obx(() => GestureDetector(
              onTap: !controller.isProcessing.value ? controller.takePicture : null,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: controller.isProcessing.value 
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : const Icon(Icons.camera_alt, size: 36, color: AppColors.primary),
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewScreen(PlantScannerController controller, bool isDarkTheme) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Captured image
              Container(
                width: double.infinity,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    controller.capturedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Prediction overlay
              Obx(() {
                if (controller.predictedPlant.value.isNotEmpty && 
                    controller.predictedPlant.value != 'Unknown Plant' &&
                    controller.canSave.value) {
                  return Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.eco, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.predictedPlant.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.verified, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Confidence: ${(controller.confidence.value * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (controller.predictedPlant.value.isNotEmpty && 
                          !controller.canSave.value) {
                  return Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Unknown Plant',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.info, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Confidence too low: ${(controller.confidence.value * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
        
        // Bottom action area - Updated for new flow
        Container(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            if (controller.predictedPlant.value.isEmpty) {
              // Initial state - show Identify button
              return Row(
                children: [
                  // Retake button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: !controller.isProcessing.value ? controller.retakePhoto : null,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Identify button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: !controller.isProcessing.value ? controller.predictPlant : null,
                      icon: controller.isProcessing.value 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.eco, size: 20),
                      label: Text(controller.isProcessing.value ? 'Analyzing...' : 'Identify Plant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // After prediction - show Retake and Save buttons
              return Row(
                children: [
                  // Retake button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: !controller.isProcessing.value ? controller.retakePhoto : null,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Save button (enabled only if canSave is true)
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: (!controller.isProcessing.value && controller.canSave.value) 
                        ? controller.savePlant 
                        : null,
                      icon: controller.isProcessing.value 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save, size: 20),
                      label: Text(
                        controller.isProcessing.value 
                          ? 'Saving...' 
                          : controller.canSave.value 
                            ? 'Save Plant' 
                            : 'Cannot Save'
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.canSave.value 
                          ? AppColors.primary 
                          : (isDarkTheme ? AppColors.darkDivider : AppColors.platinum),
                        foregroundColor: controller.canSave.value 
                          ? Colors.white 
                          : (isDarkTheme ? AppColors.darkText.withOpacity(0.5) : AppColors.charcoal.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              );
            }
          }),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(PlantScannerController controller, bool isDarkTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDarkTheme ? AppColors.darkCard : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: isDarkTheme ? AppColors.silver : AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Initializing camera...',
            style: TextStyle(
              color: isDarkTheme ? AppColors.darkText : AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: controller.retryInitialization,
            icon: Icon(
              Icons.refresh,
              color: isDarkTheme ? AppColors.silver : AppColors.primary,
            ),
            label: Text(
              'Retry',
              style: TextStyle(
                color: isDarkTheme ? AppColors.silver : AppColors.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
