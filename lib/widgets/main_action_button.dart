import 'package:flutter/material.dart';

class MainActionButton extends StatelessWidget {
  MainActionButton({
    this.onPressed,
    this.color,
    this.text,
    this.textColor,
  });

  final VoidCallback onPressed;
  final Color color;
  final String text;
  final Color textColor;

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