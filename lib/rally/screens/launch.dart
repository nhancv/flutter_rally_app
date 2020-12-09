import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rally/rally/assets.dart';
import 'package:rally/rally/rally_provider.dart';
import 'package:rally/rally/screens/main.dart';
import 'package:rally/rally/theme.dart';
import 'package:rally/rally/ui/widgets.dart';
import 'package:rally/services/app/app_dialog.dart';
import 'package:rally/services/rest_api/api_error.dart';
import 'package:rally/services/rest_api/api_error_type.dart';
import 'package:rally/services/safety/base_stateful.dart';

class LaunchScreen extends StatefulWidget {
  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends BaseStateful<LaunchScreen> with ApiError {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FocusNode _usernameFocus;
  FocusNode _passwordFocus;
  FocusNode _submitFocus;

  bool _usernameValidated;
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
    _usernameFocus = FocusNode();
    _passwordFocus = FocusNode();
    _submitFocus = FocusNode();
  }

  @override
  void dispose() {
    _submitFocus.dispose();
    _passwordFocus.dispose();
    _usernameFocus.dispose();
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
                          controller: _usernameController,
                          focusNode: _usernameFocus,
                          validator: _validateRequired('Username',
                              (bool value) => _usernameValidated = value),
                          decoration: InputDecoration(
                            suffixIcon: _buildValidationIcon(
                                context, _usernameValidated),
                            hintText: 'Username',
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(
                              Icons.fingerprint,
                              size: 72.0,
                              color: Colors.black,
                            ),
                            SizedBox(height: 8.0),
                            Text('Or login with Touch ID'),
                            SizedBox(height: 36.0),
                          ],
                        )),
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
      String fieldName, ValueSetter<bool> validated) {
    return (String value) {
      if (value == null || value.trim().isEmpty) {
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
    _onSubmitLogin();
  }

  Future<void> _onSubmitLogin() async {
    setState(() => _processing = true);

    final bool success = await apiCallSafety(() {
      return _rallyProvider.login(
          _usernameController.text, _passwordController.text);
    });

    if (mounted) {
      setState(() => _processing = false);
      if (success) {
        Navigator.of(context).push<void>(MainScreen.route());
      }
    }
  }

  @override
  Future<void> onApiError(dynamic error) async {
    final ApiErrorType errorType = parseApiErrorType(error);
    AppDialogProvider.show(context, errorType.message);
  }
}
