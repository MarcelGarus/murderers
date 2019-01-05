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
export 'models.dart';
export 'setup.dart';

/// The BLoC.
class Bloc {
  bool _introCompleted = false;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  // The handlers for all the specific tasks.
  final _account = account.Handler();
  final _messaging = messaging.Handler();

  List<Game> _games = <Game>[];
  StreamController c;
  
  /// The active game.
  final _activeGame = StreamedProperty<Game>();
  Game get activeGame => _activeGame.value;
  set activeGame(Game game) {
    assert(game == null || _games.contains(game));
    _activeGame.value = game;
  }
  get activeGameStream => _activeGame.stream;

  /// Whether the user is signed in.
  bool get isSignedIn => _account.signedInWithFirebase;


  /// This methods allows subtree widgets to access this bloc.
  static Bloc of(BuildContext context) {
    final BlocProvider holder = context.ancestorWidgetOfExactType(BlocProvider);
    return holder?.bloc;
  }

  /// Initializes the BLoC.
  void initialize() {
    c.isClosed;
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

  /// Adds or removes a game.
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
