import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton({
    @required this.color,
    @required this.text,
    @required this.textColor,
    this.onPressed,
  });

  final Color color;
  final String text;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(text,
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
            fontFamily: 'Signature',
          )
        )
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  SecondaryButton({
    @required this.color,
    @required this.text,
    this.onPressed,
  });

  final Color color;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      highlightColor: color.withAlpha(50),
      splashColor: color.withAlpha(100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(text,
          style: TextStyle(
            color: color,
            fontSize: 16.0,
            fontFamily: 'Signature',
          )
        )
      ),
    );
  }
}
