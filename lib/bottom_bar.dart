import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  BottomBar({
    this.primary = 'Next',
    this.secondary = 'Skip',
    this.onPrimary,
    this.onSecondary,
  });

  final String primary;
  final String secondary;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;

    return Material(
      elevation: 2.0,
      child: Row(
        children: <Widget>[
          _buildBottomNavigationBarButton(
            text: secondary,
            onPressed: onSecondary,
          ),
          Spacer(),
          _buildBottomNavigationBarButton(
            text: primary,
            icon: Icon(Icons.keyboard_arrow_right, color: color),
            onPressed: onPrimary,
            color: color
          ),
        ],
      )
    );
  }

  Widget _buildBottomNavigationBarButton({
    @required String text,
    Widget icon,
    @required VoidCallback onPressed,
    Color color
  }) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      containedInkWell: true,
      //radius: 100.0,
      onTap: onPressed,
      child: Container(
        height: 48.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(text.toUpperCase(),
              style: color == null ? null : TextStyle(
                fontWeight: FontWeight.bold,
                color: color
              )
            ),
            icon ?? Container(height: 0.0)
          ],
        )
      ),
    );
  }
}