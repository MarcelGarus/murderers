import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../screens/events.dart';
import '../screens/main.dart';
import '../screens/players.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/theme.dart';

class GradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyTheme.of(context).backgroundColor,
            MyTheme.of(context).backgroundGradientColor,
          ],
          begin: Alignment.bottomCenter,
        )
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    print('Building the game screen');
    return StreamBuilder(
      stream: Bloc.of(context).currentGameStream,
      builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final game = snapshot.data;
        return MyTheme(
          data: getThemeData(game),
          child: Stack(
            children: <Widget>[
              GradientBackground(),
              GameScaffold(
                main: MainScreen(game),
                left: PlayersScreen(game),
                right: EventsScreen(game),
              ),
            ],
          ),
        );
      }
    );
  }

  MyThemeData getThemeData(Game game) {
    final theme = MyTheme.of(context);

    if (game.state != GameState.running) {
      // The game is currently not running.
      return theme.copyWith(
        backgroundColor: Colors.white,
        backgroundGradientColor: Color.lerp(Colors.white, Colors.pink, 0.1),
        textColor: Colors.black,
        buttonColor: Colors.red,
        primaryButtonTextColor: Colors.white,
      );
    } else if (game.me?.isAlive ?? false) {
      // The player is alive.
      return theme.copyWith(
        backgroundColor: Colors.red,
        backgroundGradientColor: Colors.deepOrange,
        textColor: Colors.white,
        buttonColor: Colors.white,
        primaryButtonTextColor: Colors.red,
      );
    } else {
      // The player is dead.
      return theme.copyWith(
        backgroundColor: Color(0xFF222222),
        backgroundGradientColor: Color.lerp(Color(0xFF222222), Colors.deepPurple, 0.2),
        textColor: Colors.white,
        buttonColor: Colors.white,
        primaryButtonTextColor: Colors.black,
      );
    }
  }
}
