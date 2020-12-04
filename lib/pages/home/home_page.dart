import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rally/generated/l10n.dart';
import 'package:rally/pages/home/home_provider.dart';
import 'package:rally/services/app/app_dialog.dart';
import 'package:rally/services/app/app_loading.dart';
import 'package:rally/services/app/locale_provider.dart';
import 'package:rally/services/rest_api/api_error.dart';
import 'package:rally/services/rest_api/api_error_type.dart';
import 'package:rally/utils/app_constant.dart';
import 'package:rally/utils/app_log.dart';
import 'package:rally/utils/app_route.dart';
import 'package:rally/widgets/p_appbar_empty.dart';
import 'package:rally/widgets/w_dismiss_keyboard.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, ApiError {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// Log app life cycle state
    logger.d(state);
  }

  @override
  Widget build(BuildContext context) {
    // Get provider to trigger function
    final LocaleProvider localeProvider =
        Provider.of<LocaleProvider>(context, listen: false);
    return PAppBarEmpty(
      child: WDismissKeyboard(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(S.of(context).hello),
            ),

            // As default, when user change language in device setting
            // -> the locale will change appropriately
            // This button provides user can change the locale manually
            FlatButton(
              onPressed: () {
                // Get current locale
                final String currentLocale = Intl.getCurrentLocale();
                // Change to new locale
                if (currentLocale == 'en') {
                  localeProvider.locale = const Locale('vi');
                } else {
                  localeProvider.locale = const Locale('en');
                }
              },
              child: const Text('Translate'),
            ),

            const SizedBox(height: 10),
            // Example to use selector instead consumer to optimize render performance
            Selector<HomeProvider, String>(
              selector: (_, HomeProvider provider) =>
                  provider.token?.toJson()?.toString() ?? '',
              builder: (_, String tokenInfo, __) {
                return Text(
                  tokenInfo,
                  textAlign: TextAlign.center,
                );
              },
            ),

            const SizedBox(height: 10),
            // Navigate to counter page with current timestamp as argument
            RaisedButton(
              key: const Key(AppConstant.counterPageRoute),
              onPressed: () {
                Navigator.pushNamed(context, AppConstant.counterPageRoute,
                    arguments: 'From Home ${DateTime.now()}');
              },
              child: const Text('Counter Page'),
            ),

            const SizedBox(height: 10),
            // Logout
            // Navigate to login
            RaisedButton(
              key: const Key(AppConstant.loginPageRoute),
              onPressed: () async {
                _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> onApiError(dynamic error) async {
    final ApiErrorType errorType = parseApiErrorType(error);
    await AppDialogProvider.show(context, errorType.message, title: 'Error');
    await Future<void>.delayed(const Duration(seconds: 1));
    if (errorType.code == ApiErrorCode.unauthorized) {
      _logout(context);
    }
  }

  // Logout function
  Future<void> _logout(BuildContext context) async {
    final HomeProvider provider =
        Provider.of<HomeProvider>(context, listen: false);
    await apiCallSafety(
      provider.logout,
      onStart: () async {
        AppLoadingProvider.show(context);
      },
      onFinally: () async {
        AppLoadingProvider.hide(context);
        context.navigator()?.pushReplacementNamed(AppConstant.loginPageRoute);
      },
      skipOnError: false,
    );
  }
}
