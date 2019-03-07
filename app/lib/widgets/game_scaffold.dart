import 'package:flutter/material.dart';

/// A custom version of a Scaffold, providing basic structure of the main game
/// screen.
/// 
/// Displays the [left], [main] and [right] widgets next to each other.
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
