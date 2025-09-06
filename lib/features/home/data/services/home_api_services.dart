import 'package:dio/dio.dart';
import 'package:smart_irrigation_app/core/constants/API/api_urls.dart';
import 'package:smart_irrigation_app/core/network/dio_client.dart';
import 'package:smart_irrigation_app/core/utils/local_storage_service.dart';
import 'package:smart_irrigation_app/service_locator.dart';

abstract class HomeApiService {
	Future<Response> getDevices({int page = 1, int pageSize = 20});
}

class HomeApiServiceImpl implements HomeApiService {
  HomeApiServiceImpl();
  final localStorage = sl<LocalStorageService>();

	@override
	Future<Response> getDevices({int page = 1, int pageSize = 20}) async {
		// Assuming pagination query params if supported by backend
		var token = localStorage.getToken();
    var response = await sl<DioClient>().get(
			ApiUrls.device,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
			queryParameters: {
				'page': page,
				'page_size': pageSize,
			},
		);
		return response;
	}
}
