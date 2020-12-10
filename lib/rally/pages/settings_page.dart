import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rally/rally/rally_provider.dart';
import 'package:rally/services/app/app_loading.dart';
import 'package:rally/services/rest_api/api_error.dart';
import 'package:rally/services/safety/base_stateless.dart';
import 'package:rally/utils/app_constant.dart';
import 'package:rally/utils/app_route.dart';

class SettingsPage extends BaseStateless with ApiError {
  SettingsPage({Key key}) : super(key: key);

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
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        children: <Widget>[
          const Text('SETTINGS'),
          // Example to use selector instead consumer to optimize render performance
          Selector<RallyProvider, String>(
            selector: (_, RallyProvider provider) =>
                provider.user?.toString() ?? '',
            builder: (_, String userInfo, __) {
              return Column(
                children: <Widget>[
                  Text(
                    userInfo,
                    textAlign: TextAlign.center,
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await apiCallSafety(
                        _rallyProvider.logout,
                        onStart: () async {
                          AppLoadingProvider.show(context);
                        },
                        onFinally: () async {
                          AppLoadingProvider.hide(context);
                          context.navigator()?.pushReplacementNamed(
                              AppConstant.loginPageRoute);
                        },
                        skipOnError: true,
                      );
                    },
                    child: const Text('Logout'),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Future<void> onApiError(dynamic error) async {}
}
