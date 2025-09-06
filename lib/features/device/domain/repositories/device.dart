import 'package:smart_irrigation_app/features/device/domain/entities/detail_device_entity.dart';

abstract class DeviceRepository {
	Future<DetailDeviceEntity> getDeviceDetail(int deviceId);
	Future<List<PlantEntity>> getDevicePlants(int deviceId);
	Future<PlantEntity> getPlantDetail(int plantId);
}
