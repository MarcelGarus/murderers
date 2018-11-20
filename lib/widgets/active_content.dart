import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/main_action_button.dart';

class ActiveContent extends StatelessWidget {
  ActiveContent({
    @required this.game
  });
  
  final Game game;


  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Spacer()
    ];

    if (game.victim != null) {
      items.add(VictimName());
      items.add(MainActionButton(
        color: Colors.white,
        text: 'Victim killed',
        textColor: Colors.red,
      ));
    }

    items.addAll([
      Spacer(),
      Divider(height: 1.0),
      Statistics(alive: 4, dead: 4, killedByUser: 2)
    ]);

    return Column(children: items);
  }
}


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

class Statistics extends StatelessWidget {
  Statistics({
    @required this.alive,
    @required this.dead,
    @required this.killedByUser
  });

  final int alive;
  final int dead;
  final int killedByUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Spacer(),
        _buildItem(alive, 'alive', () {}),
        Spacer(flex: 2),
        _buildItem(killedByUser, 'killed by you', () {}),
        Spacer(flex: 2),
        _buildItem(dead, 'dead', () {}),
        Spacer(),
      ],
    );
  }

  Widget _buildItem(int number, String text, VoidCallback onTap) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      containedInkWell: true,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 16.0),
          Text(number.toString(),
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 8.0),
          Text(text),
          SizedBox(height: 16.0),
        ],
      )
    );
  }
}
