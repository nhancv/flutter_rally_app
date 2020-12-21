import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
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

  String get user => _api.token?.user;

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
    // Save credential
    final bool saveRes = await _credential.storeCredential(token, cache: true);
    return saveRes;
  }

  /// Call api register
  ///
  Future<bool> register(
      String firstName, String lastName, String email, String password) async {
    final Response<Map<String, dynamic>> result = await _api
        .register(firstName, lastName, email, password)
        .timeout(const Duration(seconds: 30));
    final Map<String, dynamic> data = result.data;
    print('data $data');
    if (data['id'] as String != null) {
      return true;
    }
    return false;
  }

  // Login via OpenID
  Future<bool> loginOpenId() async {
    try {
      final FlutterAppAuth appAuth = FlutterAppAuth();
      final AuthorizationTokenResponse authResponse =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          '0oa1nd3mf9SjX014I5d6',
          'com.okta.dev-6782369:/callback',
          issuer: 'https://dev-6782369.okta.com/oauth2/default',
          discoveryUrl:
              'https://dev-6782369.okta.com/oauth2/default/.well-known/openid-configuration',
          scopes: <String>['openid', 'profile', 'email', 'offline_access'],
          // ignore any existing session; force interactive login prompt
          promptValues: <String>['login'],
          loginHint: Platform.isAndroid ? '\u0002' : null,
        ),
      );
      final String accessToken = authResponse.accessToken;
      final Token token = Token(user: accessToken);
      // Save credential
      final bool saveRes =
          await _credential.storeCredential(token, cache: true);
      return saveRes;
    } catch (e) {
      throw DioError(error: 'Error: $e', type: DioErrorType.RESPONSE);
    }
  }

  /// Call logout
  Future<bool> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (user == null) {
      return true;
    }

    // Save credential
    final bool saveRes = await _credential.storeCredential(null, cache: true);
    return saveRes;
  }
}
