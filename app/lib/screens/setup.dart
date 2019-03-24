import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:intl/intl.dart';

import '../bloc/bloc.dart';
import '../widgets/app_bar.dart';
import '../widgets/button.dart';
import '../widgets/setup.dart';
import '../widgets/staggered_column.dart';
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
      Bloc.of(context).logEvent(AnalyticsEvent.join_game_begin);
      nextScreen = _EnterCodeScreen(configuration: _config);
    } else {
      // User wants to create a new game.
      Bloc.of(context).logEvent(AnalyticsEvent.create_game_begin);
      nextScreen = _ConfigureGameScreen(configuration: _config);
    }

    navigator.push(SetupRoute(nextScreen));
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: StaggeredColumn(
            children: <Widget>[
              Spacer(),
              SizedBox.fromSize(
                size: Size.square(128),
                child: FlareActor('images/logo.flr', animation: 'intro'),
              ),
              SizedBox(height: 16),
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
            ],
          ),
        ),
      )
    );
  }
}

/// Enter code.
class _EnterCodeScreen extends StatefulWidget {
  _EnterCodeScreen({
    @required this.configuration,
  });

  final SetupConfiguration configuration;

  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<_EnterCodeScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();

  String get code => widget.configuration.code;
  set code(String code) => widget.configuration.code = code;

  void initState() {
    super.initState();
    Bloc.of(context).logEvent(AnalyticsEvent.join_game_enter_code);
  }

  void _onCodeFinished(String code) {
    print('Code finished. Bloc is ${Bloc.of(context)}');
    this.code = code;
    Navigator.of(context).push(SetupRoute(_PreviewGameScreen(
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
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
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
              ),
            ),
            Button.text('Continue',
              onPressed: () => _onCodeFinished(_controller.text),
            ),
            SizedBox(height: 8),
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
class _ConfigureGameScreen extends StatefulWidget {
  _ConfigureGameScreen({
    @required this.configuration,
  });

  final SetupConfiguration configuration;

  @override
  _ConfigureGameScreenState createState() => _ConfigureGameScreenState();
}

class _ConfigureGameScreenState extends State<_ConfigureGameScreen> with TickerProviderStateMixin {
  SetupConfiguration get config => widget.configuration;

  void initState() {
    super.initState();
    Bloc.of(context).logEvent(AnalyticsEvent.create_game_enter_details);
  }

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
                onPressed: () => Bloc.of(context).createGame(
                  name: config.gameName,
                  start: DateTime.now(),
                  end: config.end,
                ),
                onSuccess: (_) {
                  Bloc.of(context).logEvent(AnalyticsEvent.create_game_completed);
                  Navigator.of(context)
                    .pushNamedAndRemoveUntil('/game', (route) => false);
                },
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
class _PreviewGameScreen extends StatefulWidget {
  _PreviewGameScreen({
    @required this.configuration,
  });

  final SetupConfiguration configuration;

  @override
  _PreviewGameScreenState createState() => _PreviewGameScreenState();
}

class _PreviewGameScreenState extends State<_PreviewGameScreen> {
  bool isReady = false;

  void initState() {
    super.initState();
    Bloc.of(context).logEvent(AnalyticsEvent.game_preview);
  }

  Future<void> _onConfirmed() async {
    final config = widget.configuration;
    final bloc = Bloc.of(context);

    Bloc.of(context).logEvent(AnalyticsEvent.join_game_completed);
    print('Setting up a game.');

    switch (config.role) {
      case UserRole.player:
        await bloc.joinGame(config.code);
        break;
      case UserRole.watcher:
        await bloc.watchGame(config.code);
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
            future: Bloc.of(context).previewGame(widget.configuration.code),
            builder: (context, snapshot) {
              if (!isReady && snapshot.connectionState == ConnectionState.done) {
                Future.delayed(Duration.zero, () {
                  VillainController.playAllVillains(context);
                });
                isReady = true;
              }

              if (snapshot.hasError) {
                return _buildError(snapshot.error);
              } else if (snapshot.hasData) {
                return _buildPreview(snapshot.data);
              } else {
                return _buildPlaceholder();
              }
            }
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      children: <Widget>[
        Spacer(flex: 2),
        CircularProgressIndicator(),
        SizedBox(height: 32),
        Text("Searching for game\nwith id ${widget.configuration.code}",
          textAlign: TextAlign.center,
        ),
        Spacer(),
        Button.text('Cancel',
          isRaised: false,
          onPressed: () => Navigator.pop(context),
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildError(dynamic error) {
    String message = '$error';

    if (error is ResourceNotFoundError) {
      message = "There's no game with the code ${widget.configuration.code}.";
    }

    return StaggeredColumn(
      children: <Widget>[
        Spacer(),
        Text(message),
        SizedBox(height: 16),
        Button.text('Back',
          isRaised: false,
          onPressed: () => Navigator.pop(context),
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildPreview(Game game) {
    var theme = MyTheme.of(context);
    var config = widget.configuration;

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
          onPressed: _onConfirmed,
          onError: (error) {}, // TODO: display error
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
