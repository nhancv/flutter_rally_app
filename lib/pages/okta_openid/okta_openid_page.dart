import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../../services/safety/base_stateful.dart';
import '../../widgets/p_appbar_empty.dart';
import '../../widgets/w_dismiss_keyboard.dart';

class OktaOpenIdPage extends StatefulWidget {
  @override
  _OktaOpenIdPageState createState() => _OktaOpenIdPageState();
}

class _OktaOpenIdPageState extends BaseStateful<OktaOpenIdPage> {
  String info;

  bool get isLogged => info != null && info.isNotEmpty;

  @override
  void initDependencies(BuildContext context) {}

  @override
  void afterFirstBuild(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PAppBarEmpty(
      child: WDismissKeyboard(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SelectableText('Info:\n$info'),
                RaisedButton(
                  onPressed: () {
                    if (isLogged == false) {
                      login();
                    } else {
                      logout();
                    }
                  },
                  child: Text(isLogged == false ? 'Login' : 'Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Logout
  void logout() {
    setState(() {
      info = null;
    });
  }

  // Login
  Future<void> login() async {
    final FlutterAppAuth appAuth = FlutterAppAuth();

    try {
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
      final String refreshToken = authResponse.refreshToken;
      final String idToken = authResponse.idToken;
      final String tokenType = authResponse.tokenType;
      final String accessTokenExpirationDateTime =
      authResponse.accessTokenExpirationDateTime.toString();
      print('info: $info');
      setState(() {
        info = '''
        accessToken: $accessToken
        refreshToken: $refreshToken
        idToken: $idToken
        tokenType: $tokenType
        accessTokenExpirationDateTime: $accessTokenExpirationDateTime
        ''';
      });
    } catch (e) {
      print(e);
    }
  }

}
