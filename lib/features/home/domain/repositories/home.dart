import 'package:smart_irrigation_app/features/home/domain/entities/device_entity.dart';

abstract class HomeRepository {
	Future<List<DeviceEntity>> getDevices({int page = 1, int pageSize = 20});
}
