import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_irrigation_app/features/auth/data/models/signup_req_param.dart';
import 'package:smart_irrigation_app/features/auth/data/services/auth_api_service.dart';
import 'package:smart_irrigation_app/features/auth/data/models/signin_req_param.dart';
import 'package:smart_irrigation_app/features/auth/domain/repositories/auth.dart';
import 'package:smart_irrigation_app/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository{
  @override
  Future<Either> signin(SigninReqParams request) async {
    Either result = await sl<AuthApiService>().signin(request);
    return result.fold(
      (error) {
        return Left(error);
      }, 
      (data) async {
        Response response = data;
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        String authToken = response.data['data']['token'];
        sharedPreferences.setString('token', authToken);
        sharedPreferences.setString('name', response.data['data']['user']['name']);
        sharedPreferences.setString('email', response.data['data']['user']['email']);
        sharedPreferences.setString('photo_profile', response.data['data']['user']['photo_profile'] ?? '');
        return Right(response);
      }
    );
  }
  
  @override
  Future<Either> signup(SignupReqParams request) async {
    Either result = await sl<AuthApiService>().signup(request);
    return result.fold(
      (error) {
        return Left(error);
      }, 
      (data) async {
        Response response = data;
        return Right(response);
      }
    );
  }
}