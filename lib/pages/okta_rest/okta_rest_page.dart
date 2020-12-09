import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app/app_loading.dart';
import '../../services/rest_api/api_user.dart';
import '../../services/safety/base_stateful.dart';
import '../../widgets/p_appbar_transparency.dart';
import '../../widgets/w_dismiss_keyboard.dart';

class OktaRestPage extends StatefulWidget {
  @override
  _OktaRestPageState createState() => _OktaRestPageState();
}

class _OktaRestPageState extends BaseStateful<OktaRestPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String info;

  bool get isLogged => info != null && info.isNotEmpty;

  @override
  void initDependencies(BuildContext context) {}

  @override
  void afterFirstBuild(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PAppBarTransparency(
      child: WDismissKeyboard(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: <Widget>[
              TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 5),
              RaisedButton(
                onPressed: () {
                  if (isLogged == false) {
                    login(_emailController.text, _passwordController.text);
                  } else {
                    logout();
                  }
                },
                child: Text(isLogged == false ? 'Login' : 'Logout'),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(info ?? ''),
                ),
              )
            ],
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
  Future<void> login(String email, String password) async {
    AppLoadingProvider.show(context);
    final Response<Map<String, dynamic>> result = await context
        .read<ApiUser>()
        .logIn(email, password)
        .timeout(const Duration(seconds: 30));
    if (result.statusCode == 200) {
      final Map<String, dynamic> data = result.data;
      print('result $data');
      // {
      // 	"expiresAt": "2020-12-09T10:24:47.000Z",
      // 	"status": "SUCCESS",
      // 	"sessionToken": "20101rVNiGQNyUrE-rTmB6-f7kgpS-mnkvXrirf5naBGYBuzBwNbor4",
      // 	"_embedded": {
      // 		"user": {
      // 			"id": "00u23168gx5gfDwUd5d8",
      // 			"passwordChanged": "2020-12-09T02:14:13.000Z",
      // 			"profile": {
      // 				"login": "xyz@email.com",
      // 				"firstName": "Dev",
      // 				"lastName": "1",
      // 				"locale": "en",
      // 				"timeZone": "America/Los_Angeles"
      // 			}
      // 		}
      // 	},
      // 	"_links": {
      // 		"cancel": {
      // 			"href": "https://dev-6782369.okta.com/api/v1/authn/cancel",
      // 			"hints": {
      // 				"allow": ["POST"]
      // 			}
      // 		}
      // 	}
      // }

      setState(() {
        info = data.toString();
      });
    } else {
      setState(() {
        info = 'Error';
      });
    }
    AppLoadingProvider.hide(context);
  }
}
