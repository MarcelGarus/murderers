import 'package:flutter/material.dart';

/// A custom theme widget that functions just like Flutter's Material ThemeData.
/// Holds some theme data for other widgets.
@immutable
class MyThemeData {
  const MyThemeData({
    @required this.backgroundColor,
    @required this.backgroundGradientColor,
    @required this.headerText,
    @required this.bodyText,
    @required this.raisedButtonFillColor,
    @required this.raisedButtonTextColor,
    @required this.flatButtonColor,
  });

  final Color backgroundColor;
  final Color backgroundGradientColor;
  final TextStyle headerText;
  final TextStyle bodyText;
  final Color raisedButtonFillColor;
  final Color raisedButtonTextColor;
  final Color flatButtonColor;

  // Copies the data with the specified changes. If a textColor or buttonColor
  // is given, the text/button colors are overwritten.
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

/// Widget that is used to propagate MyThemeData to a subtree.
class MyTheme extends StatelessWidget {
  const MyTheme({
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
      child: DefaultTextStyle(
        style: data.bodyText.copyWith(color: Colors.green),
        child: child,
      ),
    );
  }
}

/// The red accent color.
const Color kAccentColor = Colors.red;

/// Some typical properties for text.
const String kHeaderFontFamily = 'Signature';
const double kHeaderFontSize = 32;
const double kBodyFontSize = 16;

/// A light theme.
const MyThemeData kThemeLight = MyThemeData(
  backgroundColor: Colors.white,
  backgroundGradientColor: Color(0xFFFFEEFF),
  headerText: TextStyle(
    fontFamily: kHeaderFontFamily,
    fontSize: kHeaderFontSize,
    color: kAccentColor
  ),
  bodyText: TextStyle(
    color: Colors.black
  ),
  flatButtonColor: kAccentColor,
  raisedButtonFillColor: kAccentColor,
  raisedButtonTextColor: Colors.white,
);

/// A theme mainly based on the accent color.
const MyThemeData kThemeAccent = MyThemeData(
  backgroundColor: kAccentColor,
  backgroundGradientColor: Colors.deepOrange,
  headerText: TextStyle(
    fontFamily: kHeaderFontFamily,
    fontSize: kHeaderFontSize,
    color: Colors.white,
  ),
  bodyText: TextStyle(
    color: Colors.white,
  ),
  flatButtonColor: Colors.white,
  raisedButtonFillColor: Colors.white,
  raisedButtonTextColor: kAccentColor,
);

/// A dark theme.
const MyThemeData kThemeDark = MyThemeData(
  backgroundColor: Color(0xFF222222),
  backgroundGradientColor: Color(0xFF292431), // Slightly purple
  headerText: TextStyle(
    fontFamily: kHeaderFontFamily,
    fontSize: kHeaderFontSize,
    color: Colors.white,
  ),
  bodyText: TextStyle(
    color: Colors.white,
  ),
  flatButtonColor: Colors.white,
  raisedButtonFillColor: Colors.white,
  raisedButtonTextColor: Colors.black,
);
