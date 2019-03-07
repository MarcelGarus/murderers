import 'package:flutter/material.dart';

import '../../bloc/bloc.dart';
import '../../widgets/theme.dart';

class DeadDashboard extends StatelessWidget {
  DeadDashboard(this.game);
  final Game game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("You're dead.", style: MyTheme.of(context).headerText),
    );
  }
}
