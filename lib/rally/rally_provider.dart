import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:rally/models/local/token.dart';
import 'package:rally/services/cache/credential.dart';
import 'package:rally/services/rest_api/api_user.dart';
import 'package:rally/services/safety/change_notifier_safety.dart';
import 'package:rally/utils/app_log.dart';
import 'package:rally/widgets/p_web_auth.dart';

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
    logger.d('data $data');
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

  // Login social
  Future<bool> loginSocial(BuildContext context, String idName) async {
    // https://developer.okta.com/docs/reference/api/oidc/#authorize
    try {
      final Map<String, String> idps = {
        // https://console.developers.google.com/
        'google': '0oa2s9urd0fKsBsG15d6',
        // https://developers.facebook.com/
        'facebook': '0oa2se89h0ciMY7Us5d6',
        // https://www.linkedin.com/developers/
        'linkedin': '0oa2selzkzc1nrq4z5d6',
      };

      final Map<String, String> scopes = <String, String>{
        // https://developers.google.com/identity/protocols/googlescopes#google_sign-in
        'google': 'openid',
        // https://developers.facebook.com/docs/facebook-login/permissions/v2.8
        'facebook': 'openid',
        // https://developer.linkedin.com/docs/fields
        'linkedin': 'openid',
      };

      const String redirectUri = 'okta://com.okta.dev-6782369';
      final String authorizationUrl =
          'https://dev-6782369.okta.com/oauth2/v1/authorize?idp=${idps[idName]}&client_id=0oa1nd3mf9SjX014I5d6&response_type=id_token%20token&response_mode=fragment&scope=${scopes[idName]}&redirect_uri=$redirectUri&state=any&nonce=any&prompt=login';
      final String result = await Navigator.of(context)
          .push<String>(PWebAuth.route(authorizationUrl, redirectUri));

      if (result == null) {
        return false;
      }
      // Extract token from resulting url
      final Uri token = Uri.parse(result);
      // Just for easy parsing
      final String normalUrl = 'http://website/index.html?${token.fragment}';
      final String accessToken =
          Uri.parse(normalUrl).queryParameters['access_token'];
      // Save credential
      final bool saveRes = await _credential
          .storeCredential(Token(user: accessToken), cache: true);
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
