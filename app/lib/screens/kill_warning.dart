import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';
import '../widgets/theme.dart';

class KillWarning extends StatelessWidget {
  KillWarning(this.game) : assert(game.victim != null);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final victim = game.victim;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Spacer(),
              Container(width: 250, height: 150, child: Placeholder()),
              SizedBox(height: 16),
              Text('Did you kill $victim?',
                style: MyTheme.of(context).headerText,
              ),
              SizedBox(height: 8),
              Text('$victim will get notified. Make sure you gave him/her something in '
                'the real world and that you told $victim that he/she\'s dead.',
                style: MyTheme.of(context).bodyText,  
              ),
              Spacer(),
              Row(
                children: <Widget>[
                  Spacer(),
                  Button.text("Cancel",
                    isRaised: false,
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Button.text("Yes, I killed xx",
                    onPressed: () {
                      return Bloc.of(context).killPlayer();
                    },
                    onSuccess: (_) {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
