import 'package:flutter/material.dart';

class VictimName extends StatefulWidget {
  @override
  _VictimNameState createState() => _VictimNameState();
}

class _VictimNameState extends State<VictimName>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  double _showNameValue = 0.0; // ranges from 0 (name hidden) to 1 (name shown)

  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    )..addListener(() => setState(() => _showNameValue = _controller?.value));
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showName() => _controller?.forward();
  void _hideName() => _controller?.reverse();

  @override
  Widget build(BuildContext context) {
    //print('Show name is $_showName');
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      height: 160,
      child: GestureDetector(
        onPanDown: (_) => _showName,
        onPanEnd: (_) => _hideName,
        onPanCancel: _hideName,
        child: Stack(
          children: <Widget>[
            Material(
              color: Color.lerp(Colors.black12, Colors.transparent, _showNameValue),
              borderRadius: BorderRadius.circular(16),
              child: Container(),
            ),
            Opacity(
              opacity: 1 - _showNameValue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(), // to fill the whole width
                  Text('Tap & hold to reveal', style: TextStyle(color: Colors.white)),
                  Text('your first victim',
                    textScaleFactor: 2,
                    style: TextStyle(color: Colors.white, fontFamily: 'Signature')
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: _showNameValue,
              child: Align(
                alignment: Alignment.center,
                child: Text('your first victim',
                  textScaleFactor: 2,
                  style: TextStyle(color: Colors.white, fontFamily: 'Signature')
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}