import 'package:smart_irrigation_app/features/device/data/models/detail_device_model.dart';
import 'package:smart_irrigation_app/features/device/data/services/device_api_service.dart';
import 'package:smart_irrigation_app/features/device/domain/entities/detail_device_entity.dart';
import 'package:smart_irrigation_app/features/device/domain/repositories/device.dart';

class DeviceRepositoryImpl implements DeviceRepository {
	final DeviceApiService _apiService;
	DeviceRepositoryImpl(this._apiService);

	@override
	Future<DetailDeviceEntity> getDeviceDetail(int deviceId) async {
		final response = await _apiService.getDeviceDetail(deviceId);
		final data = response.data;
		if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
			return DetailDeviceModel.fromJson(data['data'] as Map<String, dynamic>).toEntity();
		}
		throw Exception('Invalid device detail response');
	}

	@override
	Future<List<PlantEntity>> getDevicePlants(int deviceId) async {
		final response = await _apiService.getDevicePlants(deviceId);
		final data = response.data;
		if (data is Map<String, dynamic> && data['data'] is List) {
			return (data['data'] as List)
					.whereType<Map<String, dynamic>>()
					.map(PlantModel.fromJson)
					.map((m) => m.toEntity())
					.toList();
		}
		return [];
	}

	@override
	Future<PlantEntity> getPlantDetail(int plantId) async {
		final response = await _apiService.getPlantDetail(plantId);
		final data = response.data;
		if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
			return PlantModel.fromJson(data['data'] as Map<String, dynamic>).toEntity();
		}
		throw Exception('Invalid plant detail response');
	}

		// Actuator actions
		Future<bool> controlActuator(int actuatorId, String action) async {
			final response = await _apiService.controlActuator(actuatorId, action);
			final data = response.data;
			if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
				return (data['data']['action'] as String).toLowerCase() == 'on';
			}
			throw Exception('Invalid actuator control response');
		}

		Future<String> changeActuatorMode(int actuatorId, String mode) async {
			final response = await _apiService.changeActuatorMode(actuatorId, mode);
			final data = response.data;
			if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
				return (data['data']['mode'] as String).toLowerCase();
			}
			throw Exception('Invalid actuator mode response');
		}
}
