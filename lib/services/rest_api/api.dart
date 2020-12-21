import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rally/models/local/token.dart';
import 'package:rally/utils/app_config.dart';

class Api {
  Api() {
    if (!kReleaseMode) {
      dio.interceptors
          .add(LogInterceptor(responseBody: true, requestBody: true));
    }
  }

  /// Credential info
  Token token;

  /// Get base url by env
  final String apiBaseUrl = Config.instance.env.apiBaseUrl;
  final Dio dio = Dio();

  /// Get request header options
  Future<Options> getOptions(
      {String contentType = Headers.jsonContentType}) async {
    final Map<String, String> header = <String, String>{};
    return Options(headers: header, contentType: contentType);
  }

  /// Get auth header options
  Future<Options> getAuthOptions({String contentType}) async {
    final Options options = await getOptions(contentType: contentType);

    if (token != null) {
      options.headers
          .addAll(<String, String>{'Authorization': 'Bearer ${token.user}'});
    }

    return options;
  }

  /// Get ApiKey to header options
  Future<Options> getApiKeyOptions({String contentType}) async {
    final Options options = await getOptions(contentType: contentType);

    final String apiKey = Config.instance.env.apiKey;
    options.headers.addAll(<String, String>{'Authorization': 'SSWS $apiKey'});

    return options;
  }

  /// Wrap Dio Exception
  Future<Response<T>> wrapE<T>(Future<Response<T>> Function() dioApi) async {
    try {
      return await dioApi();
    } catch (error) {
      if (error is DioError && error.type == DioErrorType.RESPONSE) {
        final Response<dynamic> response = error.response;

        /// if you want by pass dio header error code to get response content
        /// just uncomment line below
        //return response;
        final String errorMessage =
            'Code ${response.statusCode} - ${response.statusMessage} ${response.data != null ? '\n' : ''} ${response.data}';
        throw DioError(
            request: error.request,
            response: error.response,
            type: error.type,
            error: errorMessage);
      }
      rethrow;
    }
  }
}
