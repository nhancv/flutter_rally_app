import 'package:flutter/material.dart';

/// Widget deal with tab on screen to close keyboard
class WDismissKeyboard extends StatelessWidget {
  const WDismissKeyboard({
    @required this.child,
    this.unFocus,
    Key key,
  }) : super(key: key);

  final Widget child;
  final Function() unFocus;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (unFocus != null) {
          unFocus();
        }
      },
      child: child,
    );
  }
}
