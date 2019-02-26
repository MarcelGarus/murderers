import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';
import 'package:intl/intl.dart';

import '../bloc/bloc.dart';
import '../widgets/setup.dart';
import '../widgets/staggered_column.dart';
import '../widgets/button.dart';
import '../widgets/theme.dart';

/// A game configuration. It's passed between all the setup screens to carry
/// setup information through the setup flow.
class SetupConfiguration {
  UserRole role;
  String code;
  String gameName;
  DateTime end;
}

/// Select a mode.
class SetupJourney extends StatefulWidget {
  @override
  _SetupJourneyState createState() => _SetupJourneyState();
}

class _SetupJourneyState extends State<SetupJourney> with TickerProviderStateMixin {
  final _config = SetupConfiguration();

  void _selectRole(UserRole role) => setState(() {
    _config.role = role;
    final navigator = Navigator.of(context);
    Widget nextScreen;
    
    if (role == UserRole.player || role == UserRole.watcher) {
      // For joining a game, enter the code.
      nextScreen = EnterCodeScreen(configuration: _config);
    } else {
      // User wants to create a new game.
      nextScreen = ConfigureGameScreen(configuration: _config);
    }

    navigator.push(SetupRoute(nextScreen));
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: StaggeredColumn(
            children: <Widget>[
              Spacer(),
              Container(width: 200, height: 300, child: Placeholder()),
              SizedBox(height: 32),
              Button.text('Join a game',
                onPressed: () { _selectRole(UserRole.player); },
              ),
              SizedBox(height: 16),
              Button.text('Watch a game',
                isRaised: false,
                onPressed: () { _selectRole(UserRole.watcher); },
              ),
              SizedBox(height: 4),
              Button.text('Create a new game',
                isRaised: false,
                onPressed: () { _selectRole(UserRole.creator); },
              ),
              Spacer(),
              Button.text('Sign out',
                isRaised: false,
                onPressed: () => Bloc.of(context).signOut(),
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
        child: StaggeredColumn(
          children: <Widget>[
            Spacer(),
            Container(width: 200, height: 200, child: Placeholder()),
            Padding(
              padding: EdgeInsets.all(32),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter the code',
                  labelStyle: TextStyle(fontFamily: ''),
                ),
                style: TextStyle(
                  fontFamily: 'Mono',
                  color: Colors.black,
                  fontSize: 32
                ),
                autofocus: true,
                onChanged: (code) {
                  if (code.length >= 4) {
                    _onCodeFinished(code);
                  }
                },
              ),
            ),
            SizedBox(height: 32),
            Button.text('Cancel',
              isRaised: false,
              onPressed: () => Navigator.pop(context),
            ),
            Spacer(),
          ],
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
  SetupConfiguration get config => widget.configuration;

  Future<void> _chooseEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 5)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 7*3)),
    );
    if (pickedDate == null) return;
    // TODO: save date
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: TimeOfDay.now().hour, minute: 0),
    );
    if (pickedTime == null) return;
    final picked = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() => config.end = picked);
  }

  Future<void> _createGame() async {
    print('Creating a game.');
    await Bloc.of(context).createGame(
      name: config.gameName,
      start: DateTime.now(),
      end: config.end,
    );
    await Navigator.of(context)
      .pushNamedAndRemoveUntil('/game', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: StaggeredColumn(
            children: <Widget>[
              Spacer(),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name for the game',
                ),
                style: TextStyle(
                  fontFamily: 'Signature',
                  color: Colors.black,
                  fontSize: 32
                ),
                autofocus: true,
                onChanged: (name) => setState(() => config.gameName = name),
              ),
              SizedBox(height: 16),
              Text('When should the game end?',
                style: TextStyle(
                  fontFamily: 'Signature',
                  fontSize: 20
                ),
              ),
              Button.text(config.end == null ? 'Choose a date'
                  : DateFormat('MMMM d, H:mm').format(config.end.toLocal()),
                isRaised: false,
                onPressed: () {
                  _chooseEndDate();
                },
              ),
              SizedBox(height: 16),
              Button.text('Create game',
                onPressed: _createGame,
              ),
              SizedBox(height: 16),
              Button.text('Cancel',
                isRaised: false,
                onPressed: () => Navigator.pop(context),
              ),
              Spacer(),
            ],
          ),
        ),
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
  bool isReady = false;

  Future<void> _onConfirmed() async {
    final config = widget.configuration;
    final bloc = Bloc.of(context);

    print('Setting up a game.');

    switch (config.role) {
      case UserRole.player:
        print('Awaiting joining the game.');
        await bloc.joinGame(code: config.code);
        break;
      case UserRole.watcher:
        await bloc.watchGame(code: config.code);
        break;
      case UserRole.creator:
        await bloc.createGame(
          name: config.gameName,
          start: DateTime.now().add(Duration(days: 1)),
          end: DateTime.now().add(Duration(days: 10))
        );
        break;
    }

    await Navigator.of(context)
      .pushNamedAndRemoveUntil('/game', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FutureBuilder<Game>(
            future: Bloc.of(context).previewGame(config.code),
            builder: (context, snapshot) {
              if (!isReady && snapshot.hasData) {
                Future.delayed(Duration.zero, () {
                  VillainController.playAllVillains(context);
                });
                isReady = true;
              }

              return snapshot.hasData
                ? buildPreview(snapshot.data)
                : buildPlaceholder();
            }
          ),
        ),
      ),
    );
  }

  Widget buildPlaceholder() {
    return Column(
      children: <Widget>[
        Spacer(flex: 2),
        CircularProgressIndicator(),
        SizedBox(height: 32),
        Text("Searching for game\nwith id ${config.code}",
          textAlign: TextAlign.center,
        ),
        Spacer(),
        Button.icon(
          icon: Icon(Icons.close),
          text: 'Cancel',
          isRaised: false,
          onPressed: () => Navigator.pop(context),
        ),
        Spacer(),
      ],
    );
  }

  Widget buildPreview(Game game) {
    MyThemeData theme = MyTheme.of(context);
    return StaggeredColumn(
      children: <Widget>[
        Spacer(),
        Text("You'll be ${config.role == UserRole.player ? "joining" : "watching"}",
          style: theme.bodyText,
        ),
        SizedBox(height: 8),
        Text("${game.name}", style: theme.headerText),
        SizedBox(height: 8),
        Text("with id ${game.code}.",
          style: theme.bodyText
        ),
        SizedBox(height: 32),
        Button.text(config.role == UserRole.player ? "Join" : "Watch",
          onPressed: _onConfirmed
        ),
        SizedBox(height: 32),
        Button.text('Cancel',
          isRaised: false,
          onPressed: () => Navigator.pop(context),
        ),
        Spacer(),
      ],
    );
  }
}
