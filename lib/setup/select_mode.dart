import 'package:flutter/material.dart';
import '../bloc.dart';
import '../game.dart';
import 'configure_game.dart';
import 'enter_code.dart';
import 'setup_bloc.dart';
import 'setup_utils.dart';
import 'sign_in.dart';

class SelectModeScreen extends StatefulWidget {
  @override
  _SelectModeScreenState createState() => _SelectModeScreenState();
}

class _SelectModeScreenState extends State<SelectModeScreen> with TickerProviderStateMixin {
  void _selectRole(UserRole role) => setState(() {
    SetupBloc.of(context).role = role;
  });

  void _proceedToNextScreen() {
    final role = SetupBloc.of(context).role;
    final navigator = Navigator.of(context);
    Widget nextScreen;
    
    if (role == UserRole.PLAYER || role == UserRole.WATCHER) {
      // For joining a game, enter the code.
      nextScreen = EnterCodeScreen();
    } else {
      // User wants to create a new game.
      if (SetupBloc.of(context).canCreateNewGame) {
        nextScreen = ConfigureGameScreen();
      } else {
        // Still needs to sign in.
        nextScreen = SignInScreen(
          onSignedIn: () => navigator.push(SetupRoute(ConfigureGameScreen())),
        );
      }
    }

    navigator.push(SetupRoute(nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    final UserRole role = SetupBloc.of(context).role;

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
        onPrimary: _proceedToNextScreen,
        secondary: 'Sign out of Google', // TODO: remove
        onSecondary: () {
          MainBloc.of(context).signOut();
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
