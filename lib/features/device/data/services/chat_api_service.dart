import 'package:dio/dio.dart';
import 'package:smart_irrigation_app/core/constants/API/api_urls.dart';
import 'package:smart_irrigation_app/core/network/dio_client.dart';
import 'package:smart_irrigation_app/core/utils/local_storage_service.dart';
import 'package:smart_irrigation_app/service_locator.dart';

abstract class ChatApiService {
  Future<Response> sendMessage(String message);
}

class ChatApiServiceImpl implements ChatApiService {
  final DioClient _client;
  final LocalStorageService _localStorage = sl<LocalStorageService>();

  ChatApiServiceImpl(this._client);

  Options _withAuth() {
    final token = _localStorage.getToken();
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  @override
  Future<Response> sendMessage(String message) async {
    final body = {'message': message};
    print('=== CHAT API ===');
    print('URL: ${ApiUrls.baseUrl + '/irrigation/chat'}');
    print('Request body: $body');

    final resp = await _client.post(
      '${ApiUrls.baseUrl}/irrigation/chat',
      data: body,
      options: _withAuth(),
    );

    print('Chat API status: ${resp.statusCode}');
    print('Chat API data: ${resp.data}');
    return resp;
  }
}
