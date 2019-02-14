import 'package:flutter/material.dart';

@immutable
class MyThemeData {
  MyThemeData({
    this.backgroundColor,
    this.backgroundGradientColor,
    this.headerText,
    this.bodyText,
    this.raisedButtonFillColor,
    this.raisedButtonTextColor,
    this.flatButtonColor,
  });

  final Color backgroundColor;
  final Color backgroundGradientColor;
  final TextStyle headerText;
  final TextStyle bodyText;
  final Color raisedButtonFillColor;
  final Color raisedButtonTextColor;
  final Color flatButtonColor;

  // Copies the data with the specified changes. If a textColor or buttonColor
  // is given, the text / button colors are overridden.
  MyThemeData copyWith({
    Color backgroundColor,
    Color backgroundGradientColor,
    TextStyle headerText,
    TextStyle bodyText,
    Color primaryButtonBackgroundColor,
    Color primaryButtonTextColor,
    Color secondaryButtonColor,
    Color textColor,
    Color buttonColor,
  }) {
    return MyThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundGradientColor: backgroundGradientColor ?? this.backgroundGradientColor,
      headerText: headerText ?? ((textColor == null) ? this.headerText : this.headerText.copyWith(color: textColor)),
      bodyText: bodyText ?? ((textColor == null) ? this.bodyText : this.bodyText.copyWith(color: textColor)),
      raisedButtonFillColor: primaryButtonBackgroundColor ?? buttonColor ?? this.raisedButtonFillColor,
      raisedButtonTextColor: primaryButtonTextColor ?? this.raisedButtonTextColor,
      flatButtonColor: secondaryButtonColor ?? buttonColor ?? this.flatButtonColor,
    );
  }
}

class MyTheme extends StatelessWidget {
  MyTheme({
    Key key,
    @required this.data,
    @required this.child
  }) : super(key: key);

  final MyThemeData data;
  final Widget child;

  static MyThemeData of(BuildContext context) {
    return (context.ancestorWidgetOfExactType(MyTheme) as MyTheme)?.data;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(scaffoldBackgroundColor: data.backgroundColor),
      child: child
    );
  }
}
