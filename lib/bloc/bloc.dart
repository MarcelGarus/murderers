import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

import 'account.dart' as account;
import 'action.dart' as action;
import 'messaging.dart' as messaging;
import 'persistence.dart' as persistence;
import 'setup.dart' as setup;

import 'bloc_provider.dart';
import 'function_status.dart';
import 'models/game.dart';
import 'models/setup.dart';
import 'streamed_property.dart';

export 'bloc_provider.dart';
export 'function_status.dart';
export 'models/death.dart';
export 'models/game.dart';
export 'models/player.dart';
export 'models/setup.dart';
export 'models/user_role.dart';
export 'setup.dart';

enum GameControlResult {
  SUCCESS,
  ACCESS_DENIED,
  GAME_NOT_FOUND,
  SERVER_CORRUPT
}


/// The BLoC.
class Bloc {
  static String firebase_root = 'https://us-central1-murderers-e67bb.cloudfunctions.net';

  /// This methods allows subtree widgets to access this bloc.
  static Bloc of(BuildContext context) {
    final BlocProvider holder = context.ancestorWidgetOfExactType(BlocProvider);
    return holder?.bloc;
  }

  /// Whether the user knows the game.
  bool _knowsGame = false;

  /// Whether the user enabled notifications.
  bool _notificationsEnabled = false;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  // The handlers for all the specific tasks.
  final _account = account.Handler();
  final _messaging = messaging.Handler();

  /// The user's name.
  String _name;

  /// All the games the user participated in.
  List<Game> _games = <Game>[];
  
  /// The active game.
  final _activeGame = StreamedProperty<Game>();
  Game get activeGame => _activeGame.value;
  set activeGame(Game game) {
    assert(game == null || _games.contains(game));
    _activeGame.value = game;
  }
  get activeGameStream => _activeGame.stream;

  /// Whether the user is signed in.
  bool get isSignedIn => _account.isSignedIn;


  /// Initializes the BLoC.
  void initialize() {
    print('Initializing the BLoC.');

    // Asynchronously load the games.
    persistence.loadGames().then((games) {
      _games = games;
      if (_games.isNotEmpty) {
        activeGame = _games.first;
        updateActiveGame();
      }
    });

    // Asynchronously log app open event.
    analytics.logAppOpen();

    // Silently sign in asynchronously.
    _account.initialize();

    // Configure the messaging synchronously.
    _messaging.requestNotificationPermissions();
    _messaging.configure();
  }

  /// Disposes all the streams.
  void dispose() {
    _activeGame.dispose();
  }

  Future<bool> signIn() => _account.signIn();
  Future<void> signOut() => _account.signOut();

  // Adds or removes a game.
  void addGame(Game game) {
    _games?.add(game);
    activeGame = game;
    persistence.saveGames(_games);
  }
  void removeGame(Game game) {
    _games?.remove(game);
    activeGame = _games.isEmpty ? null : _games[0];
    game.dispose();
  }

  void updateActiveGame() {
    action.updateGame(activeGame).then((_) => activeGame = activeGame);
  }


  Future<FunctionStatus> setupGame(SetupConfiguration config) async {
    final messagingToken = await _messaging.getToken();
    final result = await setup.setupGame(config, messagingToken);
    if (result.status == FunctionStatus.success) {
      addGame(result.game);
    }
    updateActiveGame();
    return result.status;
  }

  

  Future<void> startGame() async {
    await action.startGame(activeGame);
    updateActiveGame();
  }
}
