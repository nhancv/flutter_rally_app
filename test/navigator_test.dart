import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rally/generated/l10n.dart';
import 'package:rally/pages/counter/counter_page.dart';
import 'package:rally/pages/home/home_page.dart';
import 'package:rally/pages/home/home_provider.dart';
import 'package:rally/pages/login/login_provider.dart';
import 'package:rally/services/app/app_loading.dart';
import 'package:rally/services/cache/credential.dart';
import 'package:rally/services/cache/storage.dart';
import 'package:rally/services/cache/storage_preferences.dart';
import 'package:rally/services/app/locale_provider.dart';
import 'package:rally/services/rest_api/api_user.dart';
import 'package:rally/utils/app_config.dart';
import 'package:rally/utils/app_constant.dart';
import 'package:rally/utils/app_log.dart';
import 'package:rally/utils/app_route.dart';
import 'package:rally/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Mock navigator observer class by mockito
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  // Mock navigator to verify navigation
  final MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

  // Widget to test
  Widget appWidget;

  /// Setup for test
  setUp(() {
    Config(environment: Env.dev());

    // Testing in flutter gives error MediaQuery.of() called
    // with a context that does not contain a MediaQuery
    appWidget = MediaQuery(
      data: const MediaQueryData(),
      child: MultiProvider(
        providers: <SingleChildWidget>[
          Provider<AppRoute>(create: (_) => AppRoute()),
          Provider<Storage>(create: (_) => StoragePreferences()),
          ChangeNotifierProvider<Credential>(
              create: (BuildContext context) =>
                  Credential(context.read<Storage>())),
          ProxyProvider<Credential, ApiUser>(
              create: (_) => ApiUser(),
              update: (_, Credential credential, ApiUser userApi) {
                return userApi..token = credential.token;
              }),
          Provider<AppLoadingProvider>(create: (_) => AppLoadingProvider()),
          ChangeNotifierProvider<LocaleProvider>(
              create: (_) => LocaleProvider()),
          ChangeNotifierProvider<AppThemeProvider>(
              create: (_) => AppThemeProvider()),
          ChangeNotifierProvider<HomeProvider>(
              create: (BuildContext context) => HomeProvider(
                    context.read<ApiUser>(),
                    context.read<Credential>(),
                  )),
          ChangeNotifierProvider<LoginProvider>(
              create: (BuildContext context) => LoginProvider(
                    context.read<ApiUser>(),
                    context.read<Credential>(),
                  )),
        ],
        child: Builder(
          builder: (BuildContext context) {
            final LocaleProvider localeProvider =
                context.watch<LocaleProvider>();
            final AppRoute appRoute = context.watch<AppRoute>();

            // Mock navigator Observer
            when(navigatorObserver.didPush(any, any))
                .thenAnswer((Invocation invocation) {
              logger.d('didPush ${invocation.positionalArguments}');
            });

            // Build Material app
            return MaterialApp(
              navigatorKey: appRoute.navigatorKey,
              locale: localeProvider.locale,
              supportedLocales: S.delegate.supportedLocales,
              localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              home: (appRoute.generateRoute(
                          const RouteSettings(name: AppConstant.homePageRoute))
                      as MaterialPageRoute<dynamic>)
                  .builder(context),
              onGenerateRoute: appRoute.generateRoute,
              navigatorObservers: <NavigatorObserver>[navigatorObserver],
            );
          },
        ),
      ),
    );
  });

  /// Test case:
  /// - Tap on Counter Page button
  /// - App navigate from HomePage to CounterPage
  testWidgets('Navigate from HomePage to CounterPage',
      (WidgetTester tester) async {
    // Create the widget by telling the tester to build it.
    // Build a MaterialApp with MediaQuery.
    await tester.pumpWidget(appWidget);
    // Wait the widget state updated until the LocalizationsDelegate initialized.
    await tester.pumpAndSettle();

    // Verify that HomePage displayed
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);

    // Verify that RaisedButton on screen
    final Finder counterPageFinder =
        find.byKey(const Key(AppConstant.counterPageRoute));
    expect(counterPageFinder, findsOneWidget);

    // Tap on RaisedButton
    await tester.tap(counterPageFinder);

    // Wait the widget state updated until the dismiss animation ends.
    await tester.pumpAndSettle();

    // Verify that a push event happened
    verify(navigatorObserver.didPush(any, any));

    // Verify that CounterPage opened
    expect(find.byType(CounterPage), findsOneWidget);
  });
}
