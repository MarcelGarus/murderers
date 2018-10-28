import 'package:flutter/material.dart';
import 'home.dart';
import 'choose_game.dart';

class ChooseName extends StatefulWidget {
  @override
  _ChooseNameState createState() => _ChooseNameState();
}

class _ChooseNameState extends State<ChooseName> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('The Murderer Game', style: TextStyle(color: Colors.red)),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Text("What's your name?", style: TextStyle(fontSize: 24.0)),
            SizedBox(height: 24.0),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your name',
              ),
            ),
            SizedBox(height: 16.0),
            Text('Other players will be able to see it.'),
            SizedBox(height: 16.0),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ChooseGame(),
                ));
              },
              color: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Text('Done', style: TextStyle(color: Colors.white, fontSize: 16.0)),
            )
          ],
        )
      ),
    );
  }
}
