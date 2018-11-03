import 'package:flutter/material.dart';
import '../bloc.dart';
import '../game.dart';
import 'configure_game.dart';
import 'join_game.dart';
import 'setup_utils.dart';
import 'sign_in.dart';

class SelectModeScreen extends StatefulWidget {
  @override
  _SelectModeScreenState createState() => _SelectModeScreenState();
}

class _SelectModeScreenState extends State<SelectModeScreen> with TickerProviderStateMixin {
  UserRole role = UserRole.PLAYER;

  void _selectRole(UserRole role) => setState(() {
    this.role = role;
  });

  void _next() {
    print('You chose some $role.');
    final navigator = Navigator.of(context);
    Widget nextScreen = (role == UserRole.PLAYER || role == UserRole.WATCHER)
      // If the user wants to join an existing game, let her enter the code.
      ? JoinGameScreen(role: role)
      // Otherwise (she wants to create a new game), she needs to be signed in.
      : (Bloc.of(context).isSignedIn)
      // If she is, everything's fine.
      ? ConfigureGameScreen()
      // Otherwise, display a sign in screen first.
      : SignInScreen(
        onSignedIn: () => navigator.push(SetupRoute(ConfigureGameScreen())),
      );

    navigator.push(SetupRoute(nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SetupAppBar(title: 'Choose a game mode'),
          ListTile(
            contentPadding: EdgeInsets.all(16.0),
            leading: ModeIcon(selected: role == UserRole.PLAYER, iconData: Icons.person),
            title: Text("Join as assassin", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Participate in a game and have fun killing players."),
            onTap: () => _selectRole(UserRole.PLAYER),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(16.0),
            leading: ModeIcon(selected: role == UserRole.WATCHER, iconData: Icons.remove_red_eye),
            title: Text("Join as watcher", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Watch the rankings and get notified about what's happening without actually participating."),
            onTap: () => _selectRole(UserRole.WATCHER),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(16.0),
            leading: ModeIcon(selected: role == UserRole.CREATOR, iconData: Icons.add),
            title: Text("Create new game", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Create a completely new game. Make sure you gathered other people around you who are willing to play."),
            onTap: () => _selectRole(UserRole.CREATOR),
          ),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: 'Next',
        onPrimary: _next,
        secondary: 'Sign out of Google', // TODO: remove
        onSecondary: () {
          Bloc.of(context).signOut();
        },
      ),
    );
  }
}

class ModeIcon extends StatefulWidget {
  ModeIcon({
    @required this.selected,
    @required this.iconData,
  });

  final bool selected;
  final IconData iconData;

  @override
  _ModeIconState createState() => _ModeIconState();
}

class _ModeIconState extends State<ModeIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      width: 48.0,
      decoration: BoxDecoration(
        color: widget.selected ? Colors.red : Colors.black26,
        shape: BoxShape.circle
      ), 
      child: Icon(widget.iconData, color: Colors.white)
    );
  }
}
