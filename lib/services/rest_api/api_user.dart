import 'package:dio/dio.dart';

import 'api.dart';

class ApiUser extends Api {
  /// Login
  Future<Response<Map<String, dynamic>>> logIn(
      String email, String password) async {
    final Options options = await getOptions();
    return wrapE(() => dio.post<Map<String, dynamic>>('$apiBaseUrl/v1/authn',
            options: options,
            data: <String, String>{
              'username': email,
              'password': password,
            }));
  }
}
