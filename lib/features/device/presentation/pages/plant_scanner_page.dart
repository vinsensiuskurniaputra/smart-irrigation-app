import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';

class PlantScannerPage extends StatefulWidget {
  const PlantScannerPage({super.key});

  @override
  State<PlantScannerPage> createState() => _PlantScannerPageState();
}

class _PlantScannerPageState extends State<PlantScannerPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  File? _capturedImage;
  String _predictedPlant = '';
  List<String> _detectedLabels = [];
  bool _isCaptured = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _initializeCamera();
    } else {
      // Show message that camera permission is required
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan plants'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_isInitialized) return;
    
    try {
      setState(() {
        _isProcessing = true;
      });
      
      final XFile image = await _cameraController!.takePicture();
      final File imageFile = File(image.path);
      
      setState(() {
        _capturedImage = imageFile;
        _isCaptured = true;
        _isProcessing = false;
      });
    } catch (e) {
      print('Error taking picture: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _predictPlant() async {
    if (_capturedImage == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Using ML Kit for image labeling as a placeholder
      final InputImage inputImage = InputImage.fromFile(_capturedImage!);
      final ImageLabeler labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.7));
      
      final List<ImageLabel> labels = await labeler.processImage(inputImage);
      
      List<String> plantLabels = [];
      for (ImageLabel label in labels) {
        if (label.confidence > 0.7) {
          plantLabels.add('${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)');
        }
      }
      
      // For demonstration purposes:
      // In a real app, you would use a more sophisticated plant recognition model
      // Here we simulate plant recognition with common vegetables/plants for irrigation
      String predictedPlant = "Unknown Plant";
      List<String> commonPlants = [
        'tomato', 'chili', 'lettuce', 'cucumber', 'carrot', 'potato', 'pepper',
        'basil', 'mint', 'rosemary', 'thyme', 'spinach'
      ];
      
      // Find if any label contains a plant name
      for (ImageLabel label in labels) {
        String labelText = label.label.toLowerCase();
        for (String plant in commonPlants) {
          if (labelText.contains(plant)) {
            predictedPlant = plant;
            break;
          }
        }
        if (predictedPlant != "Unknown Plant") break;
      }
      
      // If no specific plant detected, use a default if any plant-like object is detected
      if (predictedPlant == "Unknown Plant") {
        for (ImageLabel label in labels) {
          if (label.label.toLowerCase().contains('plant') || 
              label.label.toLowerCase().contains('leaf') ||
              label.label.toLowerCase().contains('flower') ||
              label.label.toLowerCase().contains('vegetable')) {
            // For demo purposes, return a random plant from our list
            predictedPlant = commonPlants[DateTime.now().millisecond % commonPlants.length];
            predictedPlant = predictedPlant.substring(0, 1).toUpperCase() + predictedPlant.substring(1);
            break;
          }
        }
      } else {
        // Capitalize the first letter
        predictedPlant = predictedPlant.substring(0, 1).toUpperCase() + predictedPlant.substring(1);
      }
      
      setState(() {
        _predictedPlant = predictedPlant;
        _detectedLabels = plantLabels;
        _isProcessing = false;
      });
      
      await labeler.close();
      
      // Return with the predicted plant
      Navigator.pop(context, {
        'plantName': _predictedPlant,
        'imageFile': _capturedImage,
      });
      
    } catch (e) {
      print('Error predicting plant: $e');
      setState(() {
        _isProcessing = false;
        _predictedPlant = 'Error: Unable to identify plant';
      });
      
      // Show error dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error identifying plant: ${e.toString().split(':').first}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _isCaptured = false;
      _predictedPlant = '';
      _detectedLabels = [];
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkTheme ? AppColors.darkBackground : AppColors.white,
      appBar: AppBar(
        backgroundColor: isDarkTheme ? AppColors.darkBackground : AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Plant Scanner',
          style: TextStyle(
            color: isDarkTheme ? AppColors.darkText : AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkTheme ? AppColors.darkText : AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isInitialized ? _buildContent(isDarkTheme) : _buildLoadingIndicator(isDarkTheme),
    );
  }

  Widget _buildContent(bool isDarkTheme) {
    if (_isCaptured && _capturedImage != null) {
      return _buildImagePreviewScreen(isDarkTheme);
    } else {
      return _buildCameraPreviewScreen(isDarkTheme);
    }
  }

  Widget _buildCameraPreviewScreen(bool isDarkTheme) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camera Preview
              ClipRRect(
                child: SizedBox(
                  width: double.infinity,
                  child: CameraPreview(_cameraController!),
                ),
              ),
              
              // Overlay frame for plant scanning
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Top-left corner
                      Positioned(
                        left: -10,
                        top: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 4),
                              left: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      
                      // Top-right corner
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 4),
                              right: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      
                      // Bottom-left corner
                      Positioned(
                        left: -10,
                        bottom: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 4),
                              left: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      
                      // Bottom-right corner
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 4),
                              right: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      
                      // Horizontal scanning line
                      Positioned(
                        left: 0,
                        right: 0,
                        top: MediaQuery.of(context).size.width * 0.4,
                        child: Container(
                          height: 2,
                          color: Colors.red.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Scanning label
              Positioned(
                bottom: 80,
                child: Text(
                  'Scanning...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Progress indicator
              Positioned(
                bottom: 50,
                left: 30,
                right: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Bottom capture area
        Container(
          height: 100,
          color: isDarkTheme ? AppColors.darkCard : AppColors.white,
          child: Center(
            child: GestureDetector(
              onTap: !_isProcessing ? _takePicture : null,
              child: Container(
                width: 70,
                height: 70,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkTheme ? AppColors.darkText : AppColors.primary,
                    width: 3,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.primary_500,
                  ),
                  child: _isProcessing 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.camera_alt, size: 32, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewScreen(bool isDarkTheme) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Captured image
              Image.file(
                _capturedImage!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
              
              // Prediction overlay if there's a result
              if (_predictedPlant.isNotEmpty && _predictedPlant != 'Unknown Plant')
                Positioned(
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _predictedPlant,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Bottom action area
        Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          color: isDarkTheme ? AppColors.darkCard : AppColors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Retake button
              Expanded(
                child: TextButton.icon(
                  onPressed: !_isProcessing ? _retakePhoto : null,
                  icon: Icon(
                    Icons.refresh,
                    color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                  ),
                  label: Text(
                    'Retake',
                    style: TextStyle(
                      color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Predict button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !_isProcessing ? _predictPlant : null,
                  icon: _isProcessing 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDarkTheme ? AppColors.darkCard : Colors.white,
                        ),
                      )
                    : const Icon(Icons.eco_outlined, size: 20),
                  label: Text(_isProcessing ? 'Processing...' : 'Identify Plant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkTheme ? AppColors.silver : AppColors.primary,
                    foregroundColor: isDarkTheme ? AppColors.darkCard : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(bool isDarkTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkTheme ? AppColors.silver : AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: TextStyle(
              color: isDarkTheme ? AppColors.darkText : AppColors.primary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              _requestCameraPermission();
            },
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
