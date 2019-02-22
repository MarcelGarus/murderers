import 'package:flutter/material.dart';

import '../../bloc/bloc.dart';
import '../../widgets/button.dart';
import '../../widgets/victim_name.dart';
import '../kill_warning.dart';

class ActiveDashboard extends StatelessWidget {
  ActiveDashboard(this.game);
  final Game game;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[ Spacer(flex: 2) ];

    if (game.victim != null) {
      items.addAll([
        VictimName(name: game.victim?.name ?? 'some victim'),
        Button(
          text: 'Victim killed',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => KillWarning(game)
            ));
          },
        ),
        SizedBox(height: 8),
        Button(
          text: 'More actions',
          isRaised: false,
          onPressed: () {},
        ),
      ]);
    }

    return Column(children: items);
  }
}
