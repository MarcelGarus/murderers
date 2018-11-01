import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'home.dart';

class ChooseGameScreen extends StatefulWidget {
  @override
  _ChooseGameScreenState createState() => _ChooseGameScreenState();
}

class _ChooseGameScreenState extends State<ChooseGameScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Material(
              elevation: 2.0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Join a game", style: TextStyle(fontFamily: 'Signature', fontSize: 24.0)),
                    SizedBox(height: 8.0),
                    Text("to make your life easier"),
                  ]
                )
              )
            ),
            SizedBox(height: 24.0),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter the code',
                  labelStyle: TextStyle(fontFamily: ''),
                ),
                style: TextStyle(fontFamily: 'Mono', color: Colors.black, fontSize: 32.0),
              ),
            ),
            SizedBox(height: 16.0),
          ],
        )
      ),
      bottomNavigationBar: BottomBar(
        primary: 'Join',
        secondary: 'Create new game',
        onPrimary: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Home(),
          ));
        },
        onSecondary: () {},
      ),
    );
  }
}
