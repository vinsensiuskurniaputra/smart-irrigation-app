import 'dart:io';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_irrigation_app/features/device/domain/usecases/predict_plant.dart';
import 'package:smart_irrigation_app/features/device/domain/usecases/save_plant.dart';
import 'package:smart_irrigation_app/service_locator.dart';

class PlantScannerController extends GetxController {
  // Observable variables
  final RxBool isInitialized = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isCaptured = false.obs;
  final RxString predictedPlant = ''.obs;
  final RxDouble confidence = 0.0.obs;
  final RxInt labelIndex = 0.obs;
  final RxBool canSave = false.obs;
  
  // Camera related
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  File? _capturedImage;
  
  // Use cases
  final PredictPlantUseCase _predictPlantUseCase = sl<PredictPlantUseCase>();
  final SavePlantUseCase _savePlantUseCase = sl<SavePlantUseCase>();
  
  // Device ID - should be passed when navigating to this page
  int? deviceId;
  
  // Getters
  CameraController? get cameraController => _cameraController;
  File? get capturedImage => _capturedImage;

  @override
  void onInit() {
    super.onInit();
    // Get device ID from route arguments if available
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map && arguments['deviceId'] != null) {
      deviceId = arguments['deviceId'] as int;
    }
    requestCameraPermission();
  }

  @override
  void onClose() {
    _cameraController?.dispose();
    super.onClose();
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await initializeCamera();
    } else {
      Get.snackbar(
        'Permission Required',
        'Camera permission is required to scan plants',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        isInitialized.value = true;
      }
    } catch (e) {
      print('Error initializing camera: $e');
      Get.snackbar(
        'Camera Error',
        'Error initializing camera: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<void> takePicture() async {
    if (_cameraController == null || !isInitialized.value) return;
    
    try {
      isProcessing.value = true;
      
      final XFile image = await _cameraController!.takePicture();
      _capturedImage = File(image.path);
      
      isCaptured.value = true;
      isProcessing.value = false;
    } catch (e) {
      print('Error taking picture: $e');
      isProcessing.value = false;
    }
  }

  Future<void> predictPlant() async {
    if (_capturedImage == null) return;
    
    isProcessing.value = true;
    
    try {
      print('Calling predict plant API...');
      final prediction = await _predictPlantUseCase.call(_capturedImage!);
      
      print('Prediction result:');
      print('- Plant: ${prediction.prediction}');
      print('- Confidence: ${prediction.confidence}');
      print('- Label Index: ${prediction.labelIndex}');
      print('- Is Confident: ${prediction.isConfident}');
      
      predictedPlant.value = prediction.prediction;
      confidence.value = prediction.confidence;
      labelIndex.value = prediction.labelIndex;
      canSave.value = prediction.isConfident && prediction.isValidLabelIndex;
      
      print('Setting canSave to: ${canSave.value} (confident: ${prediction.isConfident}, validLabel: ${prediction.isValidLabelIndex})');
      
      isProcessing.value = false;
      
      if (prediction.isConfident) {
        Get.snackbar(
          'Plant Identified',
          'Found: ${prediction.prediction} (${(prediction.confidence * 100).toStringAsFixed(1)}% confidence)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        Get.snackbar(
          'Unknown Plant',
          'Plant could not be identified with sufficient confidence. Try taking another photo.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
      
    } catch (e) {
      print('Error predicting plant: $e');
      isProcessing.value = false;
      predictedPlant.value = 'Unknown Plant';
      confidence.value = 0.0;
      canSave.value = false;
      
      Get.snackbar(
        'Identification Error',
        'Error identifying plant: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<void> savePlant() async {
    print('savePlant() called');
    print('deviceId: $deviceId');
    print('canSave: ${canSave.value}');
    print('labelIndex: ${labelIndex.value}');
    
    if (deviceId == null) {
      print('Error: deviceId is null');
      Get.snackbar(
        'Error',
        'Device ID not found. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }
    
    if (!canSave.value) {
      print('Error: canSave is false');
      Get.snackbar(
        'Cannot Save',
        'Plant confidence too low or invalid label index to save.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }
    
    // Additional validation for label index
    if (labelIndex.value < 0 || labelIndex.value > 4) {
      print('Error: Invalid label index: ${labelIndex.value}');
      Get.snackbar(
        'Cannot Save',
        'Invalid plant classification. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }
    
    isProcessing.value = true;
    
    try {
      print('Calling save plant API...');
      final savedPlant = await _savePlantUseCase.call(deviceId!, labelIndex.value);
      print('Save plant successful: ${savedPlant.plantName}');
      
      isProcessing.value = false;
      
      // Navigate back with success - let the detail device page handle the success message
      Get.back(result: {
        'success': true,
        'plant': savedPlant,
      });
      
    } catch (e) {
      print('Error saving plant: $e');
      isProcessing.value = false;
      
      Get.snackbar(
        'Save Error',
        'Error saving plant: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  void retakePhoto() {
    _capturedImage = null;
    isCaptured.value = false;
    predictedPlant.value = '';
    confidence.value = 0.0;
    labelIndex.value = 0;
    canSave.value = false;
  }

  void retryInitialization() {
    requestCameraPermission();
  }
}