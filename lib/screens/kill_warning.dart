import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';
import '../widgets/theme.dart';

class KillWarning extends StatelessWidget {
  KillWarning(this.game);

  final Game game;

  @override
  Widget build(BuildContext context) {
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
              Text('Did you kill xx?',
                style: MyTheme.of(context).headerText,
              ),
              SizedBox(height: 8),
              Text('xx will get notified. Make sure you gave him something in '
                'the real world and that you told xx that he/she\'s dead.',
                style: MyTheme.of(context).bodyText,  
              ),
              Spacer(),
              Row(
                children: <Widget>[
                  Spacer(),
                  Button(
                    text: "Cancel",
                    isRaised: false,
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Button(
                    text: "Yes, I killed xx",
                    onPressed: () async {}
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
