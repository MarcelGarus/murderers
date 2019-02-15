import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class BouncyScrollPhysics extends ScrollPhysics {
  const BouncyScrollPhysics({ ScrollPhysics parent }) : super(parent: parent);

  @override
  BouncyScrollPhysics applyTo(ScrollPhysics ancestor) {
    return BouncyScrollPhysics(parent: buildParent(ancestor));
  }

  get spring {
    print("Creating a spring.");
    return SpringDescription(mass: 2, damping: 4, stiffness: 3);
  }
}

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
    @required this.left,
    @required this.right,
  }) :
      assert(main != null),
      assert(left != null),
      assert(right != null);
  
  final Widget main;
  final Widget left;
  final Widget right;

  @override
  _GameScaffoldState createState() => _GameScaffoldState();
}

class _GameScaffoldState extends State<GameScaffold>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: WillPopScope(
        onWillPop: () async {
          if (_controller.index != 1) {
            _controller.index = 1;
            return false;
          } else return true;
        },
        child: TabBarView(
          controller: _controller,
          children: <Widget>[
            widget.left,
            widget.main,
            widget.right,
          ],
        ),
      ),
    );
  }
}
