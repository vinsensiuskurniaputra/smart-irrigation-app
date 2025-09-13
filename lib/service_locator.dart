import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_irrigation_app/core/network/dio_client.dart';
import 'package:smart_irrigation_app/core/services/connectivity_service.dart';
import 'package:smart_irrigation_app/core/utils/local_storage_service.dart';
import 'package:smart_irrigation_app/features/auth/data/services/auth_api_service.dart';
import 'package:smart_irrigation_app/features/auth/domain/repositories/auth.dart';
import 'package:smart_irrigation_app/features/auth/data/repositories/auth_impl.dart';
import 'package:smart_irrigation_app/features/auth/domain/usecases/signin_usecase.dart';
import 'package:smart_irrigation_app/features/auth/domain/usecases/signup_usecase.dart';
import 'package:smart_irrigation_app/features/home/data/services/home_api_services.dart';
import 'package:smart_irrigation_app/features/home/data/repositories/home_impl.dart';
import 'package:smart_irrigation_app/features/home/domain/repositories/home.dart';
import 'package:smart_irrigation_app/features/home/domain/usecases/get_device_list_usecase.dart';
import 'package:smart_irrigation_app/features/device/data/services/device_api_service.dart';
import 'package:smart_irrigation_app/features/device/data/services/device_websocket_service.dart';
import 'package:smart_irrigation_app/features/device/data/services/plant_prediction_api_service.dart';
import 'package:smart_irrigation_app/features/device/data/services/chat_api_service.dart';
import 'package:smart_irrigation_app/features/device/data/repositories/device_impl.dart';
import 'package:smart_irrigation_app/features/device/data/repositories/plant_prediction_impl.dart';
import 'package:smart_irrigation_app/features/device/domain/repositories/device.dart';
import 'package:smart_irrigation_app/features/device/domain/repositories/plant_prediction_repository.dart';
import 'package:smart_irrigation_app/features/device/domain/usecases/get_detail_device.dart';
import 'package:smart_irrigation_app/features/device/domain/usecases/predict_plant.dart';
import 'package:smart_irrigation_app/features/device/domain/usecases/save_plant.dart';

final sl = GetIt.instance;

void setupServiceLocator(SharedPreferences prefs) {
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<LocalStorageService>(LocalStorageServiceImpl(prefs));
  sl.registerSingleton<DioClient>(DioClient());
  sl.registerLazySingletonAsync<ConnectivityService>(() async => await ConnectivityService().init());

  //Data Source
  sl.registerSingleton<AuthApiService>(AuthApiServiceImpl());
  sl.registerSingleton<HomeApiService>(HomeApiServiceImpl());
  sl.registerSingleton<DeviceApiService>(DeviceApiServiceImpl(sl<DioClient>()));
  sl.registerSingleton<DeviceWebSocketService>(DeviceWebSocketServiceImpl(sl<LocalStorageService>()));
  sl.registerSingleton<PlantPredictionApiService>(PlantPredictionApiServiceImpl(sl<DioClient>()));
  sl.registerSingleton<ChatApiService>(ChatApiServiceImpl(sl<DioClient>()));

  // Repostory
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  sl.registerSingleton<HomeRepository>(HomeRepositoryImpl(sl<HomeApiService>()));
  sl.registerSingleton<DeviceRepository>(DeviceRepositoryImpl(sl<DeviceApiService>()));
  sl.registerSingleton<PlantPredictionRepository>(PlantPredictionRepositoryImpl(sl<PlantPredictionApiService>()));

  // Usecase
  sl.registerSingleton<SigninUseCase>(SigninUseCase());
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<GetDeviceListUseCase>(GetDeviceListUseCase(sl<HomeRepository>()));
  sl.registerSingleton<GetDetailDeviceUseCase>(GetDetailDeviceUseCase(sl<DeviceRepository>()));
  sl.registerSingleton<GetDevicePlantsUseCase>(GetDevicePlantsUseCase(sl<DeviceRepository>()));
  sl.registerSingleton<GetPlantDetailUseCase>(GetPlantDetailUseCase(sl<DeviceRepository>()));
  sl.registerSingleton<ControlActuatorUseCase>(ControlActuatorUseCase(sl<DeviceRepository>()));
  sl.registerSingleton<ChangeActuatorModeUseCase>(ChangeActuatorModeUseCase(sl<DeviceRepository>()));
  sl.registerSingleton<PredictPlantUseCase>(PredictPlantUseCase(sl<PlantPredictionRepository>()));
  sl.registerSingleton<SavePlantUseCase>(SavePlantUseCase(sl<PlantPredictionRepository>()));
}
