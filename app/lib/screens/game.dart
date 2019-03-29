import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import 'deaths.dart';
import 'dashboard.dart';
import 'players.dart';

class GameScreen extends StatelessWidget {
  final _controller = PageController();

  void _goToPage(int page) => _controller.animateToPage(page,
      curve: Curves.easeInOutCubic, duration: Duration(milliseconds: 200));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).currentGameStream,
      builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
        return (!snapshot.hasData)
            ? Center(child: CircularProgressIndicator())
            : _buildScaffold(snapshot.data);
      },
    );
  }

  Widget _buildScaffold(Game game) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: WillPopScope(
        onWillPop: () async {
          if (_controller.page == 1) {
            return true;
          }
          _goToPage(1);
          return false;
        },
        child: PageView(
          controller: _controller,
          children: <Widget>[
            PlayersScreen(game),
            DashboardScreen(
              game,
              goToPlayersCallback: () => _goToPage(0),
              goToEventsCallback: () => _goToPage(2),
            ),
            DeathsScreen(game),
          ],
        ),
      ),
    );
  }
}
