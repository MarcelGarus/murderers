import 'package:flutter/material.dart';
import '../bloc.dart';
import 'setup_utils.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({
    this.onSignedIn,
    this.onSkipped,
  });

  final VoidCallback onSignedIn;

  final VoidCallback onSkipped;
  bool get isSkippable => onSkipped != null;

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  bool signingIn = false;

  void _signIn() async {
    bool success;

    setState(() { signingIn = true; });
    try {
      success = await Bloc.of(context).signIn();
    } catch (e) { /* User aborted sign in or timeout (no internet). */ }
    setState(() { signingIn = false; });

    if (success) {
      widget.onSignedIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SetupAppBar(
            title: 'Sign in with Google',
            subtitle: widget.isSkippable ? 'to make your life easier' : null,
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            title: Text("Be lazy", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("You won't need to manually fill in your name."),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            title: Text("Start new games", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("You'll be able to start new murderer games yourself."),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            title: Text("Synchronize games", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("You'll be able to synchronize your games across all your devices."),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            title: Text("Confirm your identity", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Some games require players to be signed in so their identities can be confirmed."),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Only the game admin will be able to see your email address.",
              style: TextStyle(color: Colors.black54)
            )
          ),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: signingIn ? null : 'Sign in',
        onPrimary: signingIn ? null : _signIn,
        secondary: widget.isSkippable ? 'Skip' : null,
        onSecondary: widget.onSkipped,
      ),
    );
  }
}
