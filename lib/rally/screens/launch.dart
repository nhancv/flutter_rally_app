import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:provider/provider.dart';
import 'package:rally/rally/assets.dart';
import 'package:rally/rally/rally_provider.dart';
import 'package:rally/rally/screens/main.dart';
import 'package:rally/rally/screens/register.dart';
import 'package:rally/rally/theme.dart';
import 'package:rally/rally/ui/widgets.dart';
import 'package:rally/services/app/app_dialog.dart';
import 'package:rally/services/rest_api/api_error.dart';
import 'package:rally/services/rest_api/api_error_type.dart';
import 'package:rally/services/safety/base_stateful.dart';
import 'package:rally/utils/app_asset.dart';
import 'package:rally/utils/app_helper.dart';
import 'package:rally/utils/app_style.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchScreen extends StatefulWidget {
  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends BaseStateful<LaunchScreen> with ApiError {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FocusNode _emailFocus;
  FocusNode _passwordFocus;
  FocusNode _submitFocus;

  bool _emailValidated;
  bool _passwordValidated;

  bool _processing = false;
  bool _termsOfService = false;
  bool _privacyPolicy = false;

  RallyProvider _rallyProvider;

  @override
  void initDependencies(BuildContext context) {
    _rallyProvider = Provider.of<RallyProvider>(context, listen: false);
  }

  @override
  void afterFirstBuild(BuildContext context) {
    _rallyProvider.resetState();
  }

  @override
  void initState() {
    super.initState();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _submitFocus = FocusNode();
  }

  @override
  void dispose() {
    _submitFocus.dispose();
    _passwordFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BackgroundWidget(
      theme: AppTheme.loginTheme,
      child: Form(
        key: _formKey,
        child: ScrollviewMax(
          child: IgnorePointer(
            ignoring: _processing,
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              Images.logo,
                              width: 40.0,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                                icon: Image.asset(AppImages.icGoogle),
                                onPressed: () {
                                  loginSocial('google');
                                }),
                            IconButton(
                                icon: Image.asset(AppImages.icFacebook),
                                onPressed: () {
                                  loginSocial('facebook');
                                }),
                            IconButton(
                                icon: Image.asset(AppImages.icLinkedIn),
                                onPressed: () {
                                  loginSocial('linkedin');
                                }),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          validator: _validateRequired(
                              'Email', (bool value) => _emailValidated = value,
                              isEmail: true),
                          decoration: InputDecoration(
                            suffixIcon:
                                _buildValidationIcon(context, _emailValidated),
                            hintText: 'Email',
                          ),
                          onFieldSubmitted: _onUsernameSubmitted,
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          validator: _validateRequired('Password',
                              (bool value) => _passwordValidated = value),
                          obscureText: true,
                          decoration: InputDecoration(
                            suffixIcon: _buildValidationIcon(
                                context, _passwordValidated),
                            hintText: 'Password',
                          ),
                          onFieldSubmitted: _onPasswordSubmitted,
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                                value: _termsOfService,
                                onChanged: (bool value) {
                                  setState(() {
                                    _termsOfService = value;
                                  });
                                }),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: 'I accept App ',
                                  ),
                                  TextSpan(
                                    style: boldTextStyle(15, Colors.white),
                                    text: 'Terms of Service',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        const String url = 'https://google.com';
                                        if (await canLaunch(url)) {
                                          await launch(
                                            url,
                                            forceSafariVC: false,
                                          );
                                        }
                                      },
                                  ),
                                  const TextSpan(
                                    text: '.',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                                value: _privacyPolicy,
                                onChanged: (bool value) {
                                  setState(() {
                                    _privacyPolicy = value;
                                  });
                                }),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: 'I accept App ',
                                  ),
                                  TextSpan(
                                    style: boldTextStyle(15, Colors.white),
                                    text: 'Privacy Policy',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        const String url = 'https://google.com';
                                        if (await canLaunch(url)) {
                                          await launch(
                                            url,
                                            forceSafariVC: false,
                                          );
                                        }
                                      },
                                  ),
                                  const TextSpan(
                                    text: '.',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 36.0),
                              RaisedButton(
                                onPressed: (_emailValidated == true &&
                                        _passwordValidated == true &&
                                        _privacyPolicy == true &&
                                        _termsOfService == true)
                                    ? () {
                                        _onSubmitLogin();
                                      }
                                    : null,
                                child: const Text('Login'),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .push<void>(RegisterScreen.route());
                                },
                                child: const Text('Register'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    child: !_processing
                        ? null
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidationIcon(BuildContext context, bool validated) {
    final ThemeData theme = Theme.of(context);
    if (validated == null) {
      return null;
    }
    if (validated) {
      return Icon(Icons.check, color: theme.accentColor);
    } else {
      return Icon(Icons.close, color: theme.errorColor);
    }
  }

  FormFieldValidator<String> _validateRequired(
      String fieldName, ValueSetter<bool> validated,
      {bool isEmail = false}) {
    return (String value) {
      if (value == null ||
          value.trim().isEmpty ||
          (isEmail == true && !EmailValidator.validate(value))) {
        validated(false);
        return 'Please enter $fieldName';
      } else {
        validated(true);
        return null;
      }
    };
  }

  void _onUsernameSubmitted(String value) {
    _formKey.currentState.validate();
    FocusScope.of(context).requestFocus(_passwordFocus);
  }

  void _onPasswordSubmitted(String value) {
    _formKey.currentState.validate();
    FocusScope.of(context).requestFocus(_submitFocus);
  }

  Future<void> _onSubmitLogin() async {
    setState(() => _processing = true);

    final bool success = await apiCallSafety(() {
      return _rallyProvider.login(
          _emailController.text, _passwordController.text);
    });

    if (mounted) {
      setState(() => _processing = false);
      if (success) {
        Navigator.of(context).pushReplacement<void, void>(MainScreen.route());
      }
    }
  }

  // Login with OpenId
  Future<void> _loginWithOpenId() async {
    setState(() => _processing = true);

    final bool success = await apiCallSafety(() {
      return _rallyProvider.loginOpenId();
    });

    if (mounted) {
      setState(() => _processing = false);
      if (success) {
        Navigator.of(context).pushReplacement<void, void>(MainScreen.route());
      }
    }
  }

  // Login social
  Future<void> loginSocial(String idName) async {
    setState(() => _processing = true);

    final bool success = await apiCallSafety(() {
      return _rallyProvider.loginSocial(idName);
    });

    if (mounted) {
      setState(() => _processing = false);
      if (success) {
        Navigator.of(context).pushReplacement<void, void>(MainScreen.route());
      }
    }
  }

  @override
  Future<void> onApiError(dynamic error) async {
    final ApiErrorType errorType = parseApiErrorType(error);
    AppDialogProvider.show(context, errorType.message);
  }
}
