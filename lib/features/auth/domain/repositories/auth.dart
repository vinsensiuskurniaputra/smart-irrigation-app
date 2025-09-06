import 'package:dartz/dartz.dart';
import 'package:smart_irrigation_app/features/auth/data/models/signin_req_param.dart';
import 'package:smart_irrigation_app/features/auth/data/models/signup_req_param.dart';

abstract class AuthRepository {
  Future<Either> signin(SigninReqParams request);
  Future<Either> signup(SignupReqParams request);
}