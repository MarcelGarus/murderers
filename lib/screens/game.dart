import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import 'deaths.dart';
import 'dashboard.dart';
import 'players.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).currentGameStream,
      builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return _buildScaffold(snapshot.data);
        }
      }
    );
  }

  Widget _buildScaffold(Game game) {
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
            PlayersScreen(game),
            DashboardScreen(game,
              goToPlayersCallback: () => _controller.index = 0,
              goToEventsCallback: () => _controller.index = 2,
            ),
            DeathsScreen(game),
          ],
        ),
      ),
    );
  }
}

