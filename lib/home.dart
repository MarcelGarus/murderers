import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('The Murderer Game', style: TextStyle(color: Colors.white)),
      ),
      body: Theme(
        data: ThemeData(fontFamily: 'Signature'),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Spacer(),
              VictimName(),
              _buildVictimKilledButton(),
              Spacer(),
              Divider(height: 1.0),
              Statistics(
                alive: 4,
                dead: 4,
                killedByUser: 2,
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildVictimKilledButton() {
    return RaisedButton(
      onPressed: () {},
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Victim killed', style: TextStyle(color: Colors.red, fontSize: 16.0))
      ),
    );
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
