import 'package:dio/dio.dart';

import 'api.dart';

class ApiUser extends Api {
  /// Login
  Future<Response<Map<String, dynamic>>> logIn(
      String email, String password) async {
    final Options options = await getOptions();
    return wrapE(() => dio.post<Map<String, dynamic>>(
            '$apiBaseUrl/api/v1/authn',
            options: options,
            data: <String, String>{
              'username': email,
              'password': password,
            }));
  }

  /// Register
  /// {
  //     "id": "00u2s60s44ZAf2oRY5d6",
  //     "status": "STAGED",
  //     "created": "2020-12-21T06:25:10.000Z",
  //     "activated": null,
  //     "statusChanged": null,
  //     "lastLogin": null,
  //     "lastUpdated": "2020-12-21T06:25:10.000Z",
  //     "passwordChanged": "2020-12-21T06:25:10.000Z",
  //     "type": {
  //         "id": "oty1ncssdBNCSWYo85d6"
  //     },
  //     "profile": {
  //         "firstName": "Isaac",
  //         "lastName": "Brock",
  //         "mobilePhone": null,
  //         "secondEmail": null,
  //         "login": "isaac@test.com",
  //         "email": "isaac@test.com"
  //     },
  //     "credentials": {
  //         "password": {},
  //         "emails": [
  //             {
  //                 "value": "isaac@test.com",
  //                 "status": "VERIFIED",
  //                 "type": "PRIMARY"
  //             }
  //         ],
  //         "provider": {
  //             "type": "OKTA",
  //             "name": "OKTA"
  //         }
  //     },
  //     "_links": {
  //         "schema": {
  //             "href": "https://dev-6782369.okta.com/api/v1/meta/schemas/user/osc1ncssdBNCSWYo85d6"
  //         },
  //         "activate": {
  //             "href": "https://dev-6782369.okta.com/api/v1/users/00u2s60s44ZAf2oRY5d6/lifecycle/activate",
  //             "method": "POST"
  //         },
  //         "self": {
  //             "href": "https://dev-6782369.okta.com/api/v1/users/00u2s60s44ZAf2oRY5d6"
  //         },
  //         "type": {
  //             "href": "https://dev-6782369.okta.com/api/v1/meta/types/user/oty1ncssdBNCSWYo85d6"
  //         }
  //     }
  // }
  Future<Response<Map<String, dynamic>>> register(
      String firstName, String lastName, String email, String password) async {
    final Options options = await getApiKeyOptions();
    return wrapE(() => dio.post<Map<String, dynamic>>(
            '$apiBaseUrl/api/v1/users?activate=true',
            options: options,
            data: <String, dynamic>{
              'profile': <String, String>{
                'firstName': firstName,
                'lastName': lastName,
                'email': email,
                'login': email,
              },
              'credentials': <String, dynamic>{
                'password': <String, String>{
                  'value': password,
                },
              },
            }));
  }
}
