import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PWebAuth extends StatefulWidget {
  const PWebAuth(this.initialUrl, this.redirectUri, {Key key})
      : super(key: key);

  final String initialUrl;
  final String redirectUri;

  static Route<String> route(String authorizationUrl, String redirectUri) {
    return MaterialPageRoute<String>(
        builder: (_) => PWebAuth(authorizationUrl, redirectUri));
  }

  @override
  _PWebAuthState createState() => _PWebAuthState();
}

class _PWebAuthState extends State<PWebAuth> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  final CookieManager cookieManager = CookieManager();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cookieManager.clearCookies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        textTheme: const TextTheme(headline6: TextStyle(color: Colors.black)),
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(widget.initialUrl ?? ''),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snack bar.
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.initialUrl,
          // Fix google sign in
          userAgent: 'Chrome/56.0.0.0 Mobile',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith(widget.redirectUri)) {
              print('blocking navigation to $request}');
              Navigator.of(context).pop<String>(request.url);
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          gestureNavigationEnabled: true,
        );
      }),
    );
  }
}
