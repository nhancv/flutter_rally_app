import 'package:flutter/material.dart';

mixin AppTheme {

	static const Color backgroundColor = Color(0xFF2E2F36);
	static const Color inputColor = Color(0xFF27292F);

	static const Color greenColor = Color(0xFF1EB980);
	static const Color greenColor1 = Color(0xFF29524F);
	static const Color greenColor2 = Color(0xFF56AD79);
	static const Color greenColor3 = Color(0xFF7AE7B6);
	static const Color greenColor4 = Color(0xFF37704C);

	static const Color yellowColor1 = Color(0xFFFDDD78);
	static const Color yellowColor2 = Color(0xFFF96A51);
	static const Color yellowColor3 = Color(0xFFFFD7CF);
	static const Color yellowColor4 = Color(0xFFFFA808);

	static const Color panelColor = Color(0xFF363840);

	static final ThemeData theme = ThemeData(
		brightness: Brightness.dark,
		backgroundColor: backgroundColor,
		accentColor: greenColor,
		//fontFamily: 'Roboto Condensed'
	);

	static final ThemeData loginTheme = theme.copyWith(
		inputDecorationTheme: const InputDecorationTheme(
			fillColor: inputColor,
			filled: true,
			border: InputBorder.none,
		),
	);
}
