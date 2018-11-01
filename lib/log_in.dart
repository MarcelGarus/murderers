import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'bottom_bar.dart';
import 'choose_game.dart';

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> with TickerProviderStateMixin {
  void _signIn() async {
    final account = await GoogleSignIn.standard(
      scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
    ).signIn();

    print(account);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChooseGameScreen(),
    ));
  }

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
                    Text("Log in with Google", style: TextStyle(fontFamily: 'Signature', fontSize: 24.0)),
                    SizedBox(height: 8.0),
                    Text("to make your life easier"),
                  ]
                )
              )
            ),
            ListTile(
              title: Text("Start new games", style: TextStyle(fontFamily: 'Signature')),
              subtitle: Text("You'll be able to start new murderer games yourself."),
            ),
            ListTile(
              title: Text("Synchronize games", style: TextStyle(fontFamily: 'Signature')),
              subtitle: Text("You'll be able to synchronize your games across all your devices."),
            ),
            ListTile(
              title: Text("Be lazy", style: TextStyle(fontFamily: 'Signature')),
              subtitle: Text("You won't need to fill in your name."),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Other players won't be able to see your email address.",
                style: TextStyle(color: Colors.black54)
              )
            ),
          ],
        )
      ),
      bottomNavigationBar: BottomBar(
        primary: 'Log in',
        secondary: 'Skip',
        onPrimary: _signIn,
      ),
    );
  }
}
