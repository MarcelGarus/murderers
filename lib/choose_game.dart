import 'package:flutter/material.dart';
import 'home.dart';

class ChooseGame extends StatefulWidget {
  @override
  _ChooseGameState createState() => _ChooseGameState();
}

class _ChooseGameState extends State<ChooseGame> with TickerProviderStateMixin {
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
            Text("Join game", style: TextStyle(fontSize: 24.0)),
            SizedBox(height: 24.0),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter the code',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(child: Container(color: Colors.black, height: 3.0)),
                SizedBox(width: 16.0),
                Text('OR'),
                SizedBox(width: 16.0),
                Expanded(child: Container(color: Colors.black, height: 3.0)),
              ],
            ),
            SizedBox(height: 16.0),
            Text('Create game', style: TextStyle(fontSize: 24.0)),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Home(),
                ));
              },
              color: Colors.red,
              child: Text('Create a new game'),
            )
          ],
        )
      ),
    );
  }
}
