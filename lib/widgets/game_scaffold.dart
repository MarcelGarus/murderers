import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// A custom version of a Scaffold, adding the basic structure of this app.
/// 
/// There are customary [configure], [fab], [frontCard] and [backCard]
/// properties, that display all the widgets in the right position.
/// 
/// A bottom app bar is automatically created with the given FAB, a menu button
/// (see [onMenuTapped]) and an arrow (if [canResumeGame] is set to true).
/// 
/// Furthermore, fancy support for two different kinds of gestures is added:
/// * The stack gesture allows users to swipe up from the bottom bar of the
///   configure screen in order to resume a running game. Alternatively, they
///   can press the arrow button on the right or start a new game.
/// * The cards gesture is also built-in into the Scaffold, allowing the easy
///   dismissal of the front card. Once the card is dismissed, [onDismissed] is
///   invoked.
class GameScaffold extends StatefulWidget {
  GameScaffold({
    @required this.main,
    @required this.bar,
    @required this.players,
  }) :
      assert(main != null),
      assert(bar != null),
      assert(players != null);
  
  final Widget main;
  final Widget bar;
  final Widget players;

  @override
  _GameScaffoldState createState() => _GameScaffoldState();
}

class _GameScaffoldState extends State<GameScaffold>
    with SingleTickerProviderStateMixin {
  static const double _barHeight = 72;

  // Variables for the swipe up gesture. The _pos value can reach from 0.0
  // (players hidden) to 1.0 (players fully visible).
  double _pos = 0;
  double _posWhenDragStarted = 0;
  Offset _dragStart;
  AnimationController _controller;
  Animation<double> _animation;

  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this
    )..addListener(() => setState(() {
      _pos = _animation?.value ?? 0;
    }));
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animatePlayers(double target, { double velocity }) {
    _animation = Tween(begin: _pos, end: target).animate(_controller);
    _controller
      ..value = 0.0
      ..fling(velocity: velocity ?? 2.0);
  }

  // Helping variables for rendering.
  Size get screen => MediaQuery.of(context).size;
  double get animationHeight => screen.height - _barHeight;

  // Touch handlers for a stack drag.
  void _onDragDown(DragDownDetails details) {
    _dragStart = details.globalPosition;
    _posWhenDragStarted = _pos;
  }

  void _onDragUpdate(DragUpdateDetails details) => setState(() {
    final visibilityDelta = (_dragStart - details.globalPosition).dy
        / animationHeight;
    _pos = (_posWhenDragStarted + visibilityDelta).clamp(0, 1);
  });

  void _onDragEnd(DragEndDetails details) {
    final dragVelocity = details.velocity.pixelsPerSecond.dy / 1000;
    final visibilityVelocity = -dragVelocity / screen.height;
    final extrapolatedVisibility = _pos + visibilityVelocity * 1500;
    final targetVisibility = extrapolatedVisibility.clamp(0, 1).roundToDouble();

    _animatePlayers(targetVisibility, velocity: dragVelocity.abs());
  }

  // The position of the bottom part (stack + FAB). Effectively top of FAB.
  double get _playersResting => screen.height;
  double get _playersVisible => _barHeight;
  double get _playersOffset => lerpDouble(_playersResting, _playersVisible, _pos);
  double get _barBottom => screen.height - _barHeight;
  double get _barTop => 0;
  double get _barOffset => lerpDouble(_barBottom, _barTop, _pos);
  
  // The size of the safe area.
  double get safeAreaSize => MediaQuery.of(context).padding.top * _pos;

  @override
  Widget build(BuildContext context) {
    final main = widget.main;
    final players = Transform(
      transform: Matrix4.translationValues(0, _playersOffset, 0),
      child: widget.players
    );
    final bar = Transform(
      transform: Matrix4.translationValues(0, _barOffset, 0),
      child: GestureDetector(
        onVerticalDragDown: _onDragDown,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: widget.bar,
      ),
    );

    // Everything.
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (_pos == 0) return true;
          _animatePlayers(0);
          return false;
        },
        child: Stack(children: [ main, players, bar ]),
      )
    );
  }
}
