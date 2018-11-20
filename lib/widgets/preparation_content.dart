import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import 'main_action_button.dart';

class PreparationContent extends StatelessWidget {
  PreparationContent({
    @required this.game
  });
  
  final Game game;


  void _startGame(BuildContext context) {
    Bloc.of(context).startGame();
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Text(game.code,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Signature',
          fontSize: 92.0,
        )
      ),
      SizedBox(height: 8.0),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          "Share this code with other people \n to let them join.",
          style: TextStyle(
            fontFamily: 'Signature'
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ];

    if (game.myRole == UserRole.CREATOR) {
      items.addAll([
        SizedBox(height: 16.0),
        MainActionButton(
          onPressed: () => _startGame(context),
          color: Colors.black,
          text: 'Start the game',
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
}