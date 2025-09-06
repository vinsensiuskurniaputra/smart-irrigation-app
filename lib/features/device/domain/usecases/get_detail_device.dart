import 'package:smart_irrigation_app/features/device/domain/entities/detail_device_entity.dart';
import 'package:smart_irrigation_app/features/device/domain/repositories/device.dart';

class GetDetailDeviceUseCase {
	final DeviceRepository repository;
	const GetDetailDeviceUseCase(this.repository);
	Future<DetailDeviceEntity> call(int deviceId) => repository.getDeviceDetail(deviceId);
}

class GetDevicePlantsUseCase {
	final DeviceRepository repository;
	const GetDevicePlantsUseCase(this.repository);
	Future<List<PlantEntity>> call(int deviceId) => repository.getDevicePlants(deviceId);
}

class GetPlantDetailUseCase {
	final DeviceRepository repository;
	const GetPlantDetailUseCase(this.repository);
	Future<PlantEntity> call(int plantId) => repository.getPlantDetail(plantId);
}
