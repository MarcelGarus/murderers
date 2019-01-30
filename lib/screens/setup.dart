import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/setup.dart';
import '../widgets/primary_button.dart';

/// A game configuration. It's passed between all the setup screens to carry
/// setup information through the setup flow.
class SetupConfiguration {
  UserRole role;
  String code;
  String gameName;
}


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
    _proceedToNextScreen();
  });

  void _proceedToNextScreen() {
    final navigator = Navigator.of(context);
    Widget nextScreen;
    
    if (role == UserRole.player || role == UserRole.watcher) {
      // For joining a game, enter the code.
      nextScreen = EnterCodeScreen(configuration: config);
    } else {
      // User wants to create a new game.
      nextScreen = ConfigureGameScreen(configuration: config);
    }

    navigator.push(SetupRoute(nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200,
                height: 300,
                child: Placeholder(),
              ),
              SizedBox(height: 32),
              PrimaryButton(
                color: Colors.red,
                text: 'Join a game',
                textColor: Colors.white,
                onPressed: () => _selectRole(UserRole.player),
              ),
              SizedBox(height: 16),
              SecondaryButton(
                color: Colors.red,
                text: 'Watch a game',
                onPressed: () => _selectRole(UserRole.watcher),
              ),
              SizedBox(height: 4),
              SecondaryButton(
                color: Colors.red,
                text: 'Create a new game',
                onPressed: () => _selectRole(UserRole.watcher),
              ),
            ],
          ),
        ),
      )
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 200,
              height: 200,
              child: Placeholder(),
            ),
            Padding(
              padding: EdgeInsets.all(32.0),
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
          ],
        ),
      ),
      bottomNavigationBar: SetupBottomBar(),
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
    Navigator.of(context).push(
      SetupRoute(SetupFinishedScreen(configuration: config))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("You'll be joining",
                textScaleFactor: 1.2,
              ),
              SizedBox(height: 8),
              Text("${widget.configuration.code}",
                textScaleFactor: 2.5,
                style: TextStyle(color: Colors.red, fontFamily: 'Signature'),
              ),
              SizedBox(height: 8),
              Text("as a\n${widget.configuration.role}",
                textAlign: TextAlign.center,
                textScaleFactor: 1.2,
              ),
              SizedBox(height: 32),
              PrimaryButton(
                color: Colors.red,
                text: "Join",
                textColor: Colors.white,
                onPressed: _onConfirmed,
              ),
            ],
          ),
        ),
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
          SectionHeader('Joining the game'),
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
            title: Text("Publish murderer", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("When a player dies, the murderer's name will be shown to all players. This is a disadvantage for the murderer, if the victim's victim knows the victim was supposed to be his assassin."),
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
    _setItUp();
  }

  void _setItUp() async {
    final config = widget.configuration;
    final bloc = Bloc.of(context);
    Result<Game> result;

    print('Setting up a game.');

    switch (config.role) {
      case UserRole.player:
        print('Awaiting joining the game.');
        result = await bloc.joinGame(code: config.code);
        break;
      case UserRole.watcher:
        result = await bloc.watchGame(code: config.code);
        break;
      case UserRole.creator:
        result = await bloc.createGame(
          name: config.gameName,
          start: DateTime.now().add(Duration(days: 1)),
          end: DateTime.now().add(Duration(days: 10))
        );
        break;
    }

    if (result.didSucceed) {
      print('Game created successfully.');
      await Navigator.of(context)
        .pushNamedAndRemoveUntil('/game', (route) => false);
    } else {
      print('Creating the game failed.');
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
