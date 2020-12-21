import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Environment declare here
class Env {
  Env._({
    @required this.apiBaseUrl,
    @required this.apiKey,
  });

  /// Dev mode
  factory Env.dev() {
    return Env._(
      apiBaseUrl: 'https://dev-6782369.okta.com',
      apiKey: '00as7LbKEx3UUO91M-xgHWzW3mMPbn8Vga91-lQnET',
    );
  }

  final String apiBaseUrl;
  final String apiKey;
}

/// Config env
class Config {
  factory Config({Env environment}) {
    if (environment != null) {
      instance.env = environment;
    }
    return instance;
  }

  Config._private();

  static final Config instance = Config._private();

  Env env;
}
