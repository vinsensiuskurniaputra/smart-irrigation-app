import 'package:dio/dio.dart';
import 'package:smart_irrigation_app/core/constants/API/api_urls.dart';
import 'package:smart_irrigation_app/core/network/dio_client.dart';
import 'package:smart_irrigation_app/core/utils/local_storage_service.dart';
import 'package:smart_irrigation_app/service_locator.dart';

abstract class DeviceApiService {
	Future<Response> getDeviceDetail(int deviceId);
	Future<Response> getDevicePlants(int deviceId);
	Future<Response> getPlantDetail(int plantId);
	Future<Response> controlActuator(int actuatorId, String action);
	Future<Response> changeActuatorMode(int actuatorId, String mode);
}

class DeviceApiServiceImpl implements DeviceApiService {
	final DioClient _client;
	final LocalStorageService _localStorage = sl<LocalStorageService>();
	DeviceApiServiceImpl(this._client);

	Options _withAuth() {
		final token = _localStorage.getToken();
		return Options(headers: {
			'Authorization': 'Bearer $token',
		});
	}

	@override
	Future<Response> getDeviceDetail(int deviceId) {
		return _client.get(
			'${ApiUrls.device}/$deviceId',
			options: _withAuth(),
		);
	}

	@override
	Future<Response> getDevicePlants(int deviceId) {
		return _client.get(
			'${ApiUrls.baseUrl}/irrigation/devices/$deviceId/plants',
			options: _withAuth(),
		);
	}

	@override
	Future<Response> getPlantDetail(int plantId) {
		return _client.get(
			'${ApiUrls.baseUrl}/irrigation/plants/$plantId',
			options: _withAuth(),
		);
	}

		@override
		Future<Response> controlActuator(int actuatorId, String action) {
			return _client.post(
				'${ApiUrls.actuator}/$actuatorId/control',
				data: {'action': action},
				options: _withAuth(),
			);
		}

		@override
		Future<Response> changeActuatorMode(int actuatorId, String mode) {
			return _client.put(
				'${ApiUrls.actuator}/$actuatorId/mode',
				data: {'mode': mode},
				options: _withAuth(),
			);
		}
}
