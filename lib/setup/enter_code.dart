import 'package:flutter/material.dart';
import 'package:code_input/code_input.dart';
import '../game.dart';
import 'setup_utils.dart';
import 'confirm_game.dart';

class EnterCodeScreen extends StatefulWidget {
  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SetupAppBar(
            title: 'Join a game',
            subtitle: 'by entering the code',
          ),
          SizedBox(height: 24.0),
          CodeInput(length: 4),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter the code',
                labelStyle: TextStyle(fontFamily: ''),
              ),
              style: TextStyle(fontFamily: 'Mono', color: Colors.black, fontSize: 32.0),
              autofocus: true,
              onChanged: (code) {
                if (code.length >= 4) {
                  Navigator.of(context).push(SetupRoute(ConfirmGameScreen()));
                }
              },
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(),
    );
  }
}
