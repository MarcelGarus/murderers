import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/setup.dart';
import 'game.dart';

/// Select a mode.
class SetupJourney extends StatefulWidget {
  @override
  _SetupJourneyState createState() => _SetupJourneyState();
}

class _SetupJourneyState extends State<SetupJourney> with TickerProviderStateMixin {
  final config = SetupConfiguration();
  UserRole get role => config.role;

  void _selectRole(UserRole role) => setState(() {
    config.role = role;
  });

  void _proceedToNextScreen() {
    final navigator = Navigator.of(context);
    Widget nextScreen;
    
    if (role == UserRole.player || role == UserRole.watcher) {
      // For joining a game, enter the code.
      nextScreen = EnterCodeScreen(configuration: config);
    } else {
      // User wants to create a new game.
      if (Bloc.of(context).isSignedIn) {
        nextScreen = ConfigureGameScreen(configuration: config);
      } else {
        // Still needs to sign in.
        nextScreen = SignInScreen(
          onSignedIn: () => navigator.push(SetupRoute(ConfigureGameScreen(
            configuration: config
          ))),
        );
      }
    }

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
            leading: ModeIcon(selected: role == UserRole.player, iconData: Icons.person),
            title: Text("Join as assassin", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Participate in a game and have fun killing players."),
            onTap: () => _selectRole(UserRole.player),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(16.0),
            leading: ModeIcon(selected: role == UserRole.watcher, iconData: Icons.remove_red_eye),
            title: Text("Join as watcher", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Watch the rankings and get notified about what's happening without actually participating."),
            onTap: () => _selectRole(UserRole.watcher),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(16.0),
            leading: ModeIcon(selected: role == UserRole.creator, iconData: Icons.add),
            title: Text("Create new game", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Create a completely new game. Make sure you gathered other people around you who are willing to play."),
            onTap: () => _selectRole(UserRole.creator),
          ),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: 'Next',
        onPrimary: _proceedToNextScreen,
        secondary: 'Sign out of Google', // TODO: remove
        onSecondary: () {
          Bloc.of(context).signOut();
        },
      ),
    );
  }
}


/// Enter code.
class EnterCodeScreen extends StatefulWidget {
  EnterCodeScreen({
    @required this.configuration,
  });

  final SetupConfiguration configuration;

  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> with TickerProviderStateMixin {
  String get code => widget.configuration.code;
  set code(String code) => widget.configuration.code = code;

  void _onCodeFinished(String code) {
    print('Code finished. Bloc is ${Bloc.of(context)}');
    this.code = code;
    Navigator.of(context).push(SetupRoute(ConfirmGameScreen(
      configuration: widget.configuration
    )));
  }

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
                  _onCodeFinished(code);
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


/// Sign in.
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


/// Enter the name.
class EnterNameScreen extends StatefulWidget {
  EnterNameScreen({
    @required this.configuration,
  });

  final SetupConfiguration configuration;

  @override
  _EnterNameScreenState createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> with TickerProviderStateMixin {
  final controller = TextEditingController();

  void _onNameEntered(String name) {
    widget.configuration.playerName = name;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SetupFinishedScreen(configuration: widget.configuration),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SetupAppBar(
            title: "What's your name?",
          ),
          SizedBox(height: 24.0),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Enter first and last name",
            ),
          ),
          SizedBox(height: 16.0),
          Text('Other players will be able to see it. To counter confusion in large groups, it\'s recommended to enter both your first and last name.'),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: 'Done',
        onPrimary: () => _onNameEntered(controller.text),
      ),
    );
  }
}


/// Confirm game.
class ConfirmGameScreen extends StatefulWidget {
  ConfirmGameScreen({
    @required this.configuration,
  });

  final SetupConfiguration configuration;

  @override
  _ConfirmGameScreenState createState() => _ConfirmGameScreenState();
}

class _ConfirmGameScreenState extends State<ConfirmGameScreen> with TickerProviderStateMixin {
  SetupConfiguration get config => widget.configuration;
  UserRole get role => config.role;
  String get code => config.code;

  void _onConfirmed() {
    final navigator = Navigator.of(context);
    Widget nextScreen = EnterNameScreen(configuration: config);
    
    // If the user doesn't want to play, the setup is finished. Otherwise, we
    // need a name. If already signed in, we use that, else we offer to sign in
    // and then continue to the game or - if skipped - enter the name manually.
    /*if (role != UserRole.player || Bloc.of(context).isSignedIn) {
      nextScreen = SetupFinishedScreen(configuration: config);
    } else {
      nextScreen = SignInScreen(
        onSignedIn: () => navigator.push(SetupRoute(SetupFinishedScreen(configuration: config))),
        onSkipped: () => navigator.push(SetupRoute(EnterNameScreen(configuration: config))),
      );
    }*/

    navigator.push(SetupRoute(nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SetupAppBar(
            title: widget.configuration.role == UserRole.creator ? 'Create a game' : 'Join a game'
          ),
          SizedBox(height: 24.0),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("You'll be joining"),
              Text('${widget.configuration.code}'),
              Text('as a'),
              Text(widget.configuration.role.toString())
            ],
          ),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: "Join",
        onPrimary: _onConfirmed,
        secondary: 'Cancel',
        onSecondary: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}


/// Configure the game.
class ConfigureGameScreen extends StatefulWidget {
  ConfigureGameScreen({
    @required this.configuration,
  });

  final SetupConfiguration configuration;

  @override
  _ConfigureGameScreenState createState() => _ConfigureGameScreenState();
}

class _ConfigureGameScreenState extends State<ConfigureGameScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SetupAppBar(
            title: 'Configure your game',
            subtitle: 'Adjust everything just like you want it to be',
          ),
          SectionHeader('Game metadata'),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Name", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Give your game a name. This could be the name of the event where this game takes place."),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Code", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("The game code that allows other players to join will be generated when the game is created."),
          ),
          SectionHeader('Joining the game'),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Only signed in players", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Only allow players to join that signed in with their Google account. This allows for easy identity confirmation."),
            trailing: Switch(value: false, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Confirm players", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Once players join, you'll need to approve them before they're actually added to the game."),
            trailing: Switch(value: false, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Joining to running game", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Players that join while the game is running will be added the next time a player gets killed."),
            trailing: Switch(value: false, onChanged: null),
          ),
          SectionHeader('Gameplay'),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Custom rule", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text('You can provide a custom definition of killing. Note that your definition still needs to be legal, so no real killing please.'),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Configure running game", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Do you want to be able to configure the game while it's running? If you do so, you cannot participate, as you'd be able to cheat."),
            trailing: Switch(value: false, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Murder weapon", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Allow players to enter the murder weapon once they're killed."),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Last words", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Allow players to enter their last words once they're killed."),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Publish murderer", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("When a player dies, the murderer's name will be shown to all players. This is a disadvantage for the murderer, if the victim's victim knows the victim was supposed to be his assassin."),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Provide deaths right away", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("All players will get notified as soon as a death occurs."),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Send out daily summaries", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Send out daily summaries of how many players got killed etc."),
            trailing: Switch(value: true, onChanged: null),
          ),
          SectionHeader('End of the game'),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("End timestamp", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Provide a specific point in time when the game will end."),
          ),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: "Create game",
        onPrimary: () {
          Navigator.of(context).push(SetupRoute(ConfirmGameScreen(configuration: widget.configuration)));
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  SectionHeader(this.text);
  
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 4.0),
      child: Text(text,
        style: TextStyle(
          fontFamily: 'Signature',
          color: Theme.of(context).primaryColor
        )
      ),
    );
  }
}


/// Setup finished.
class SetupFinishedScreen extends StatefulWidget {
  SetupFinishedScreen({
    @required this.configuration
  });

  final SetupConfiguration configuration;

  @override
  _SetupFinishedScreenState createState() => _SetupFinishedScreenState();
}

class _SetupFinishedScreenState extends State<SetupFinishedScreen> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    final config = widget.configuration;

    print('Setting up a game for user ${config.playerName}.');
    Bloc.of(context).setupGame(config).then(_finished);
  }

  void _finished(FunctionStatus result) {
    // If it succeeded, the new active game is already set and the setup widget
    // subtree will be replaced by the game screen. That means, we only need to
    // handle the error cases in here.

    if (result == FunctionStatus.success) {
      print('Game couldnt be created.');
      // TODO: display appropriate error and offer to retry
    }
  }

  @override
  Widget build(BuildContext context) {
    String text = (widget.configuration.role == UserRole.creator)
      ? "Wait while your game\nis being created."
      : "Wait while you're\njoining the game.";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text(text, style: TextStyle(fontFamily: 'Signature'), textAlign: TextAlign.center),
          ],
        ),
      )
    );
  }
}

