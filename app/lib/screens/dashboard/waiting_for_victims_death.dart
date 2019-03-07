import 'package:flutter/material.dart';

import '../../bloc/bloc.dart';
import '../../widgets/theme.dart';

class WaitingForVictimsDeathDashboard extends StatelessWidget {
  WaitingForVictimsDeathDashboard(this.game);
  final Game game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Spacer(),
          Text('Waiting for your victim\'s approval.',
            style: MyTheme.of(context).bodyText,
          ),
          Spacer(),
        ]
      )
    );
  }
}
