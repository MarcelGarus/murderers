import 'package:flutter/material.dart';

class VictimName extends StatefulWidget {
  @override
  _VictimNameState createState() => _VictimNameState();
}

class _VictimNameState extends State<VictimName> {
  bool showName = false;

  void _onDown() {
    setState(() {
      showName = true;
    });
  }

  void _onUp() {
    setState(() {
      showName = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (d) => _onDown(),
      onPanEnd: (d) => _onUp(),
      onPanCancel: _onUp,
      child: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        height: 160.0,
        child: Stack(
          children: <Widget>[
            showName ? Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child:  Text('Marcel Garus',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 32.0)
              ),
            ) : Container(),
            showName ? Container() : Material(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Tap & hold to reveal', style: TextStyle(color: Colors.white)),
                    Text('your first victim', style: TextStyle(color: Colors.white, fontSize: 32.0)),
                  ],
                )
              ),
            ),
          ]
        )
      )
    );
  }
}