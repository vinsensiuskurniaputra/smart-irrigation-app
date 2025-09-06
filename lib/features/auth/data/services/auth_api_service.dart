import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:smart_irrigation_app/core/constants/API/api_urls.dart';
import 'package:smart_irrigation_app/core/network/dio_client.dart';
import 'package:smart_irrigation_app/features/auth/data/models/signin_req_param.dart';
import 'package:smart_irrigation_app/features/auth/data/models/signup_req_param.dart';
import 'package:smart_irrigation_app/service_locator.dart';

abstract class AuthApiService {
  Future<Either> signin(SigninReqParams request);
  Future<Either> signup(SignupReqParams request);
}

class AuthApiServiceImpl extends AuthApiService {
  @override
  Future<Either> signin(SigninReqParams request) async {
    try {
      var response = await sl<DioClient>().post(
        ApiUrls.login,
        data: request.toMap(),
      );

      return Right(response);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message'].toString());
      } else {
        return Left(e.message);
      }
    } catch (e) {
      return Left('Unexpected error');
    }
  }
  
  @override
  Future<Either> signup(SignupReqParams request) async {
    try {
      var response = await sl<DioClient>().post(
        ApiUrls.register,
        data: request.toMap(),
      );

      return Right(response);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['error'].toString());
      } else {
        return Left(e.message);
      }
    } catch (e) {
      return Left('Unexpected error');
    }
  }
  
}
