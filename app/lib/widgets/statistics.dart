import 'package:flutter/material.dart';

import '../bloc/bloc.dart';

class Statistics extends StatelessWidget {
  Statistics({
    this.goToPlayersCallback,
    this.goToEventsCallback,
    this.color,
  }) :
      assert(goToPlayersCallback != null),
      assert(goToEventsCallback != null);

  final VoidCallback goToPlayersCallback;
  final VoidCallback goToEventsCallback;
  final Color color;

  @override
  Widget build(BuildContext context) {
    var game = Bloc.of(context).currentGame;
    assert(game != null);

    var myRank = game.me?.rank;
    var killedByMe = game.me?.kills ?? 0;
    var alive = game.players.where((p) => p.isAlive).length;
    var total = game.players.length;

    return Row(
      children: <Widget>[
        _buildItem(
          number: myRank == null ? '-' : '#$myRank',
          text: 'rank',
          onTap: goToPlayersCallback,
        ),
        _buildItem(
          number: '$killedByMe',
          text: 'killed by you',
        ),
        _buildItem(
          number: '$alive/$total',
          text: 'still alive',
          onTap: goToEventsCallback,
        ),
      ],
    );
  }

  Widget _buildItem({ String number, String text, VoidCallback onTap }) {
    return Expanded(
      child: InkResponse(
        highlightShape: BoxShape.rectangle,
        containedInkWell: true,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 16),
            Text(number,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8),
            Text(text, style: TextStyle(color: color)),
            SizedBox(height: 16),
          ],
        )
      ),
    );
  }
}
