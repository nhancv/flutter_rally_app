import 'package:dio/dio.dart';
import 'package:rally/models/local/token.dart';
import 'package:rally/services/cache/credential.dart';
import 'package:rally/services/rest_api/api_user.dart';
import 'package:rally/services/safety/change_notifier_safety.dart';

class RallyProvider extends ChangeNotifierSafety {
  RallyProvider(this._api, this._credential);

  // Authentication api
  final ApiUser _api;

  // Credential
  final Credential _credential;

  @override
  void resetState() {}

  /// Call api login
  Future<bool> login(String email, String password) async {
    final Response<Map<String, dynamic>> result =
        await _api.logIn(email, password).timeout(const Duration(seconds: 30));
    final Map<String, dynamic> data = result.data;
    final Map<String, dynamic> _embedded =
        data['_embedded'] as Map<String, dynamic>;
    final String user = (_embedded['user'] as Map<String, dynamic>).toString();
    final Token token = Token(user: user);
    if (token != null) {
      // Save credential
      final bool saveRes =
          await _credential.storeCredential(token, cache: true);
      return saveRes;
    } else {
      throw DioError(error: 'Login error', type: DioErrorType.RESPONSE);
    }
  }
}
