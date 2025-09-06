import 'package:dartz/dartz.dart';
import 'package:smart_irrigation_app/features/auth/data/models/signin_req_param.dart';
import 'package:smart_irrigation_app/features/auth/domain/repositories/auth.dart';
import 'package:smart_irrigation_app/service_locator.dart';

class SigninUseCase{
  Future<Either> call({required String username, required String password}) async {
    return sl<AuthRepository>().signin(SigninReqParams(username: username, password: password));
  }
}
