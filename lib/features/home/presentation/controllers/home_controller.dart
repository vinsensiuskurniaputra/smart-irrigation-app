import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_irrigation_app/core/utils/page_status.dart';
import 'package:smart_irrigation_app/service_locator.dart';
import 'package:smart_irrigation_app/features/home/domain/entities/device_entity.dart';
import 'package:smart_irrigation_app/features/home/domain/usecases/get_device_list_usecase.dart';

class HomeController extends GetxController {
  var status = PageStatus.initial.obs;
  var errorMessage = ''.obs;
  var name = 'User'.obs;
  var devices = <DeviceEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchName();
    fetchDevices();
  }

  Future<void> fetchName() async {
    try {
      final nameUser = sl<SharedPreferences>().getString('name');
      name.value = nameUser ?? 'User';
    } catch (e) {
      errorMessage.value = 'Failed to load name: ${e.toString()}';
    }
  }

  void fetchData() async {
    try {

      // On success
      status.value = PageStatus.success;
    } catch (e) {
      status.value = PageStatus.error;
      errorMessage.value = 'Failed to fetch data: ${e.toString()}';
    }
  }

  Future<void> fetchDevices() async {
    status.value = PageStatus.loading;
    try {
      final useCase = sl<GetDeviceListUseCase>();
      final result = await useCase();
      devices.assignAll(result);
      status.value = PageStatus.success;
    } catch (e) {
      status.value = PageStatus.error;
      errorMessage.value = 'Failed to fetch devices: ${e.toString()}';
    }
  }
}