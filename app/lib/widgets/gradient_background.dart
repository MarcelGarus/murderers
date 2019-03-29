import 'package:flutter/material.dart';

import 'theme.dart';

/// A widget typically used to function as the background of a screen.
/// Displays a gradient of the two background colors of the enclosing theme.
class GradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = MyTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.backgroundColor, theme.backgroundGradientColor],
          begin: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
