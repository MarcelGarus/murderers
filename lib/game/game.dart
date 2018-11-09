import 'package:flutter/material.dart';
import 'game_bloc.dart';
import '../game.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: GameBloc.of(context).game,
      builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
        if (!snapshot.hasData) {
          print('No data to display.');
          return Container();
        }

        final game = snapshot.data;
        return Scaffold(
          backgroundColor: _getBackgroundColor(game),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Text('The Murderer Game',
              style: TextStyle(color: Colors.black)
            ),
          ),
          body: Theme(
            data: ThemeData(fontFamily: 'Signature'),
            child: SafeArea(
              child: game.state == GameState.NOT_STARTED_YET
                ? _buildNotStartedYetContent(game)
                : _buildStartedContent(game)
            ),
          )
        );
      }
    );
  }

  Color _getBackgroundColor(Game game) {
    return (game.state == GameState.NOT_STARTED_YET)
      ? Colors.white
      : !(game.me?.isAlive ?? true)
      ? Colors.black
      : (game.state == GameState.RUNNING)
      ? Colors.red
      : Colors.white;
  }


  // Displays the code for joining the game.
  Widget _buildNotStartedYetContent(Game game) {
    final items = <Widget>[
      Text(game.code,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Signature',
          fontSize: 92.0,
        )
      ),
    ];

    if (game.myRole == UserRole.CREATOR) {
      items.addAll([
        SizedBox(height: 16.0),
        MainActionButton(
          onPressed: () {},
          color: Colors.black,
          text: 'Start game',
          textColor: Colors.white,
        )
      ]);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items
      )
    );
  }


  // The game is already running, so display the actual content.
  Widget _buildStartedContent(Game game) {
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
        child: Text(text, style: TextStyle(color: textColor, fontSize: 16.0))
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
