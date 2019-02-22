import 'dart:ui';

import 'package:flutter/material.dart';

import 'theme.dart';

/// A widget that displays the victim's name.
/// 
/// In its natural state, this widget displays a message that encourages the
/// user to press and hold. If he does this, the [name] appears.
class VictimName extends StatefulWidget {
  VictimName({
    @required this.name,
  }) :
      assert(name != null);

  final String name;

  @override
  _VictimNameState createState() => _VictimNameState();
}

class _VictimNameState extends State<VictimName>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  double _nameVisibility = 0; // ranges from 0 (name hidden) to 1 (name shown)

  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    )..addListener(() => setState(() {
      _nameVisibility = _animation?.value ?? 0;
    }));
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setNameVisibility(double visibility) {
    _animation = Tween(begin: _nameVisibility, end: visibility)
      .animate(_controller);
    _controller..value = 0.0..forward();
  }
  void _showName() => _setNameVisibility(1);
  void _hideName() => _setNameVisibility(0);

  double get _nameScale => Curves.easeOut.transform(_nameVisibility);
  double get _blurSigma => (1 - _nameVisibility) * 10.0;
  double get _nameOpacity => (5 * _nameVisibility).clamp(0.0, 1.0);
  double get _hintOpacity => (1 - 1.5 * _nameVisibility).clamp(0.0, 1.0);
  Color get _backgroundColor => Color.lerp(
    Color(0x19000000), Colors.transparent, _nameVisibility);

  @override
  Widget build(BuildContext context) {
    final theme = MyTheme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      height: 160,
      child: GestureDetector(
        onPanDown: (_) => _showName(),
        onPanEnd: (_) => _hideName(),
        onPanCancel: _hideName,
        child: Stack(
          children: <Widget>[
            Opacity(
              opacity: _nameOpacity,
              child: Align(
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: _nameScale,
                  child: Text(widget.name, style: theme.headerText),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
                child: Container(color: _backgroundColor),
              ),
            ),
            Opacity(
              opacity: _hintOpacity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(), // to fill the whole width
                  Text('Tap & hold to reveal', style: theme.bodyText),
                  Text('your victim', style: theme.headerText),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
