import 'package:smart_irrigation_app/features/home/domain/entities/device_entity.dart';
import 'package:smart_irrigation_app/features/home/domain/repositories/home.dart';

class GetDeviceListUseCase {
	final HomeRepository repository;
	const GetDeviceListUseCase(this.repository);

	Future<List<DeviceEntity>> call({int page = 1, int pageSize = 20}) async {
		return repository.getDevices(page: page, pageSize: pageSize);
	}
}
