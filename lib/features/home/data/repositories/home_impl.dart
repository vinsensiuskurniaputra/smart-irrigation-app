import 'package:smart_irrigation_app/features/home/data/models/device_model.dart';
import 'package:smart_irrigation_app/features/home/data/services/home_api_services.dart';
import 'package:smart_irrigation_app/features/home/domain/entities/device_entity.dart';
import 'package:smart_irrigation_app/features/home/domain/repositories/home.dart';

class HomeRepositoryImpl implements HomeRepository {
	final HomeApiService _apiService;
	HomeRepositoryImpl(this._apiService);

	@override
	Future<List<DeviceEntity>> getDevices({int page = 1, int pageSize = 20}) async {
		final response = await _apiService.getDevices(page: page, pageSize: pageSize);
		final data = response.data;
		if (data is Map<String, dynamic>) {
			final list = data['data'];
			if (list is List) {
				return list
						.whereType<Map<String, dynamic>>()
						.map((json) => DeviceModel.fromJson(json))
						.map((model) => DeviceEntity(
									id: model.id,
									deviceName: model.deviceName,
									deviceCode: model.deviceCode,
									status: model.status,
								))
						.toList();
			}
		}
		return [];
	}
}
