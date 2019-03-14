import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:firebase_analytics/observer.dart';

import 'account.dart' as account;
import 'analytics.dart' as analytics;
import 'network.dart' as network;
import 'messaging.dart' as messaging;
import 'persistence.dart' as persistence;

import 'bloc_provider.dart';
import 'models.dart';
import 'streamed_property.dart';

export 'bloc_provider.dart';
export 'function_status.dart';
export 'models.dart';
export 'analytics.dart' show AnalyticsEvent;
export 'account.dart' show SignInType;
export 'network.dart' show NetworkError, NoConnectionError, BadRequestError, ServerCorruptError, AuthenticationFailedError, ResourceNotFoundError;

/// The BLoC.
class Bloc {
  // The handlers for all the specific tasks.
  final _account = account.Handler();
  final _analytics = analytics.Handler();
  final _network = network.Handler();
  final _messaging = messaging.Handler();

  List<Game> _games = <Game>[];
  final _currentGame = StreamedProperty<Game>();

  /// This methods allows subtree widgets to access this bloc.
  static Bloc of(BuildContext context) {
    final BlocProvider holder = context.ancestorWidgetOfExactType(BlocProvider);
    return holder?.bloc;
  }

  /// Initializes the BLoC.
  void initialize() {
    print('Initializing the BLoC.');

    // Silently sign in asynchronously. Then, asynchronously load the games.
    _account.initialize().then((_) {
      persistence.loadGames().then((games) async {
        _games = games;
        _games.forEach(_messaging.subscribeToGame);
        if (_games.isNotEmpty) {
          final current = await persistence.loadCurrentGame();
          currentGame = _games.singleWhere((g) => g.code == current);
          await refreshGame();
        }
      });
    });

    // Asynchronously log app open event.
    _analytics.initialize();

    // Configure the messaging synchronously.
    _messaging.requestNotificationPermissions();
    _messaging.configure(onMessageReceived: () async {
      await refreshGame();
    });
    _messaging.subscribeToDeaths();
  }

  /// Disposes all the streams.
  void dispose() {
    _currentGame.dispose();
  }

  // Handles the sign in status.
  Future<void> signIn(account.SignInType type) => _account.signIn(type);
  Future<bool> signOut() => _account.signOut();
  bool get isSignedIn => _account.isSignedInWithFirebase;

  // Handles the account.
  Future<void> createAccount(String name) async {
    return await _account.createUser(_network, _messaging, name);
  }
  bool get hasAccount => _account.userWasCreated;

  String get name => _account.name;
  set name(String name) => _account.rename(_network, name); // TODO: handle result

  String get accountPhotoUrl => _account.photoUrl;

  List<Game> get allGames => _games;

  // The current game.
  Game get currentGame => _currentGame.value;
  set currentGame(Game game) {
    assert(game == null || _games.contains(game));
    print("Setting current game to $game");
    _currentGame.value = game;
    persistence.saveCurrentGame(game?.code ?? '');
  }
  get currentGameStream => _currentGame.stream;
  bool get hasCurrentGame => currentGame != null;
  
  /// Logs an event.
  void logEvent(
    analytics.AnalyticsEvent event, [
    Map<String, dynamic> parameters
  ]) {
    assert(event != null);
    _analytics.logEvent(event, parameters);
  }
  FirebaseAnalyticsObserver get analyticsObserver => _analytics.observer;

  Future<Game> previewGame(String code) async {
    return await _network.getGame(
      id: _account.id,
      authToken: _account.authToken,
      code: code
    );
  }

  Future<Game> watchGame({ @required String code }) async {
    // TODO: implement
    return null;
  }

  Future<Game> joinGame({ @required String code }) async {
    assert(_account.userWasCreated);
    
    final existingGame = _games.singleWhere((game) => game.code == code);
    if (existingGame?.isPlayer ?? false) {
      return existingGame;
    }

    await _network.joinGame(
      id: _account.id,
      authToken: _account.authToken,
      code: code
    );
    return await _network.getGame(
      id: _account.id,
      authToken: _account.authToken,
      code: code,
    ).then(_addGame);
  }

  Future<Game> createGame({
    @required String name,
    @required DateTime start,
    @required DateTime end,
  }) async {
    assert(_account.userWasCreated);

    return await _network.createGame(
      id: _account.id,
      authToken: _account.authToken,
      name: name,
      start: start,
      end: end
    ).then(_addGame);
  }

  Future<Game> _addGame(Game game) async {
    assert(game != null);

    _games
      ..removeWhere((g) => g.code == game.code)
      ..add(game);
    currentGame = game;
    await persistence.saveGames(_games);
    return game;
  }

  // TODO: if we're a player or creator, disallow or notify server
  void removeGame(Game game) async {
    _games.remove(game);
    if (!_games.contains(currentGame)) {
      currentGame = _games.isEmpty ? null : _games.first;
    }
    await persistence.saveGames(_games);
  }

  void _updateCurrentGame(Game game) async {
    _games.remove(currentGame);
    _games.add(game);
    currentGame = game;
    await persistence.saveGames(_games);
  }

  Future<Game> refreshGame() async {
    final game = await _network.getGame(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code
    );
    logEvent(analytics.AnalyticsEvent.game_loaded, { 'code': game.code });
    _updateCurrentGame(game);
    return game;
  }

  Future<void> acceptPlayers({ @required List<Player> players }) async {
    await _network.acceptPlayer(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code,
      players: players,
    );
    await refreshGame();
  }

  Future<void> startGame() async {
    await _network.startGame(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code,
    );
    await refreshGame();
  }

  Future<void> killPlayer() async {
    await _network.killPlayer(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code
    );
    await refreshGame();
  }

  Future<void> confirmDeath({
    @required String weapon,
    @required String lastWords,
  }) async {
    await _network.die(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code,
      weapon: weapon,
      lastWords: lastWords,
    );
    await refreshGame();
  }

  Future<void> shuffleVictims(bool onlyOutsmartedPlayers) async {
    await _network.shuffleVictims(
      authToken: _account.authToken,
      code: currentGame.code,
      onlyOutsmartedPlayers: onlyOutsmartedPlayers,
    );
    await refreshGame();
  }
}
