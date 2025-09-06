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

final sl = GetIt.instance;

void setupServiceLocator(SharedPreferences prefs) {
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<LocalStorageService>(LocalStorageServiceImpl(prefs));
  sl.registerSingleton<DioClient>(DioClient());
  sl.registerLazySingletonAsync<ConnectivityService>(() async => await ConnectivityService().init());

  //Data Source
  sl.registerSingleton<AuthApiService>(AuthApiServiceImpl());

  // Repostory
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Usecase
  sl.registerSingleton<SigninUseCase>(SigninUseCase());
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
}
