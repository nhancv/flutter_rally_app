import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
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
import 'package:rally/utils/app_helper.dart';

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
                              width: 140.0,
                            ),
                          ),
                        ),
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
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              // const Icon(
                              //   Icons.fingerprint,
                              //   size: 72.0,
                              //   color: Colors.black,
                              // ),
                              // const SizedBox(height: 8.0),
                              // const Text('Or login with Touch ID'),
                              // const SizedBox(height: 36.0),
                              // RaisedButton(
                              //   onPressed: () {
                              //     _loginWithOpenId();
                              //   },
                              //   child: const Text('Login with OpenId'),
                              // ),
                              // const SizedBox(height: 36.0),
                              const SizedBox(height: 36.0),
                              RaisedButton(
                                onPressed: (_emailValidated == true &&
                                        _passwordValidated == true)
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

  // Login with OpenId
  Future<void> _registerWithUsernamePassword() async {
    setState(() => _processing = true);

    final bool success = await apiCallSafety(() {
      return _rallyProvider.login(
          _emailController.text, _passwordController.text);
    });

    if (mounted) {
      setState(() => _processing = false);
      AppHelper.showToast(success ? 'Success' : 'Error');
    }
  }

  @override
  Future<void> onApiError(dynamic error) async {
    final ApiErrorType errorType = parseApiErrorType(error);
    AppDialogProvider.show(context, errorType.message);
  }
}
