import 'dart:io';
import 'package:dio/dio.dart';
import 'package:smart_irrigation_app/core/constants/API/api_urls.dart';
import 'package:smart_irrigation_app/core/network/dio_client.dart';
import 'package:smart_irrigation_app/core/utils/local_storage_service.dart';
import 'package:smart_irrigation_app/service_locator.dart';

abstract class PlantPredictionApiService {
  Future<Response> predictPlant(File imageFile);
  Future<Response> savePlant(int deviceId, int labelIndex);
}

class PlantPredictionApiServiceImpl implements PlantPredictionApiService {
  final DioClient _client;
  final LocalStorageService _localStorage = sl<LocalStorageService>();
  
  PlantPredictionApiServiceImpl(this._client);

  Options _withAuth() {
    final token = _localStorage.getToken();
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  @override
  Future<Response> predictPlant(File imageFile) async {
    print('=== PREDICT PLANT API ===');
    print('Image file path: ${imageFile.path}');
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'plant_image.jpg',
      ),
    });

    print('API URL: ${ApiUrls.plantPredict}');
    print('FormData created successfully');

    final response = await _client.post(
      ApiUrls.plantPredict,
      data: formData,
      options: _withAuth(),
    );
    
    print('Predict API Response status: ${response.statusCode}');
    print('Predict API Response data: ${response.data}');
    
    return response;
  }

  @override
  Future<Response> savePlant(int deviceId, int labelIndex) {
    print('=== SAVE PLANT API ===');
    print('Device ID: $deviceId');
    print('Label Index: $labelIndex');
    print('API URL: ${ApiUrls.savePlant(deviceId)}');
    print('Request body: {"label_index": $labelIndex}');
    
    final response = _client.post(
      ApiUrls.savePlant(deviceId),
      data: {'label_index': labelIndex},
      options: _withAuth(),
    );
    
    response.then((resp) {
      print('Save API Response status: ${resp.statusCode}');
      print('Save API Response data: ${resp.data}');
    }).catchError((error) {
      print('Save API Error: $error');
      if (error is DioException) {
        print('Save API Error Response: ${error.response?.data}');
        print('Save API Error Status: ${error.response?.statusCode}');
      }
    });
    
    return response;
  }
}
