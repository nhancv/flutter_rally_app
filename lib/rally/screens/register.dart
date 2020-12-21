import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rally/rally/assets.dart';
import 'package:rally/rally/rally_provider.dart';
import 'package:rally/rally/theme.dart';
import 'package:rally/rally/ui/widgets.dart';
import 'package:rally/services/app/app_dialog.dart';
import 'package:rally/services/rest_api/api_error.dart';
import 'package:rally/services/rest_api/api_error_type.dart';
import 'package:rally/services/safety/base_stateful.dart';
import 'package:rally/utils/app_helper.dart';

class RegisterScreen extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return RegisterScreen();
      },
    );
  }

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends BaseStateful<RegisterScreen> with ApiError {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FocusNode _firstNameFocus;
  FocusNode _lastNameFocus;
  FocusNode _emailFocus;
  FocusNode _passwordFocus;
  FocusNode _submitFocus;

  bool _firstNameValidated;
  bool _lastNameValidated;
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
    _firstNameFocus = FocusNode();
    _lastNameFocus = FocusNode();
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
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          validator: _validateRequired('First name',
                              (bool value) => _firstNameValidated = value),
                          decoration: InputDecoration(
                            suffixIcon: _buildValidationIcon(
                                context, _firstNameValidated),
                            hintText: 'First name',
                          ),
                          onFieldSubmitted: _onFirstNameSubmitted,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _lastNameController,
                          focusNode: _lastNameFocus,
                          validator: _validateRequired('Last name',
                              (bool value) => _lastNameValidated = value),
                          decoration: InputDecoration(
                            suffixIcon: _buildValidationIcon(
                                context, _lastNameValidated),
                            hintText: 'Last name',
                          ),
                          onFieldSubmitted: _onLastNameSubmitted,
                          textInputAction: TextInputAction.next,
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
                          onFieldSubmitted: _onEmailSubmitted,
                          textInputAction: TextInputAction.next,
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
                              const SizedBox(height: 36.0),
                              RaisedButton(
                                onPressed: (_emailValidated == true &&
                                        _passwordValidated == true)
                                    ? () {
                                        _register();
                                      }
                                    : null,
                                child: const Text('Register'),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Login'),
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

  void _onFirstNameSubmitted(String value) {
    _formKey.currentState.validate();
    FocusScope.of(context).requestFocus(_lastNameFocus);
  }

  void _onLastNameSubmitted(String value) {
    _formKey.currentState.validate();
    FocusScope.of(context).requestFocus(_emailFocus);
  }

  void _onEmailSubmitted(String value) {
    _formKey.currentState.validate();
    FocusScope.of(context).requestFocus(_passwordFocus);
  }

  void _onPasswordSubmitted(String value) {
    _formKey.currentState.validate();
    FocusScope.of(context).requestFocus(_submitFocus);
  }

  // Register
  Future<void> _register() async {
    setState(() => _processing = true);

    final bool success = await apiCallSafety(() {
      return _rallyProvider.register(
          _firstNameController.text,
          _lastNameController.text,
          _emailController.text,
          _passwordController.text);
    });

    if (mounted) {
      setState(() => _processing = false);
      AppHelper.showToast(success == true ? 'Success' : 'Error');
      if (success == true) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Future<void> onApiError(dynamic error) async {
    final ApiErrorType errorType = parseApiErrorType(error);
    AppDialogProvider.show(context, errorType.message);
  }
}
