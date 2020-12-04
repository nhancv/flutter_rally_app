import 'package:flutter/material.dart';
import 'package:rally/rally/screens/launch.dart';
import 'package:rally/rally/theme.dart';

class RallyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rally',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: LaunchScreen(),
    );
  }
}
