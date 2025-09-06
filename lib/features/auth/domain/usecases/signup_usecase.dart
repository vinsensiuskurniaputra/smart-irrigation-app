import 'package:dartz/dartz.dart';
import 'package:smart_irrigation_app/features/auth/data/models/signup_req_param.dart';
import 'package:smart_irrigation_app/features/auth/domain/repositories/auth.dart';
import 'package:smart_irrigation_app/service_locator.dart';

class SignupUseCase{
  Future<Either> call({required String username, required String password, required String name, required String email}) async {
    return sl<AuthRepository>().signup(SignupReqParams(username: username, password: password, name: name, email: email));
  }
}
