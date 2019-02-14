import 'dart:async';

//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

import 'account.dart' as account;
import 'network.dart' as network;
import 'messaging.dart' as messaging;
import 'persistence.dart' as persistence;

import 'bloc_provider.dart';
import 'models/game.dart';
import 'streamed_property.dart';

export 'bloc_provider.dart';
export 'function_status.dart';
export 'models.dart';
export 'account.dart' show SignInType;
export 'network.dart' show NetworkError, NoConnectionError, BadRequestError, ServerCorruptError, AuthenticationFailedError, ResourceNotFoundError;

/// The BLoC.
class Bloc {
  //FirebaseAnalytics analytics = FirebaseAnalytics();

  // The handlers for all the specific tasks.
  final _account = account.Handler();
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

    // Asynchronously load the games.
    /*persistence.loadGames().then((games) async {
      _games = games;
      if (_games.isNotEmpty) {
        final current = await persistence.loadCurrentGame();
        currentGame = _games.singleWhere((g) => g.code == current);
      }
    });*/

    // Asynchronously log app open event.
    //analytics.logAppOpen();

    // Silently sign in asynchronously.
    _account.initialize();

    // Configure the messaging synchronously.
    _messaging.requestNotificationPermissions();
    _messaging.configure();
  }

  /// Disposes all the streams.
  void dispose() {
    _currentGame.dispose();
  }

  Future<bool> signIn(account.SignInType type) => _account.signIn(type);

  Future<bool> signOut() => _account.signOut();

  bool get isSignedIn => _account.isSignedInWithFirebase;

  Future<void> createAccount(String name) async {
    return await _account.createUser(_network, _messaging, name);
  }

  bool get hasAccount => _account.userWasCreated;

  String get name => _account.name;
  set name(String name) => _account.rename(_network, name); // TODO: handle result

  List<Game> get allGames => _games;

  Game get currentGame => _currentGame.value;
  set currentGame(Game game) {
    assert(game == null || _games.contains(game));
    print("Setting current game to $game");
    _currentGame.value = game;
    persistence.saveCurrentGame(game?.code ?? '');
  }
  get currentGameStream => _currentGame.stream;
  
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

    await _network.joinGame(
      id: _account.id,
      authToken: _account.authToken,
      code: code
    );
    return await _network.getGame(
      id: _account.id,
      authToken: _account.authToken,
      code: code
    ).then(_addGame);
  }

  Future<Game> createGame({
    @required String name,
    @required DateTime start,
    @required DateTime end
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

    _games.add(game);
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
    _updateCurrentGame(game);
    return game;
  }

  Future<void> startGame() async {
    await _network.startGame(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code
    );
    return await refreshGame();
  }

  Future<void> killPlayer() async {
    await _network.killPlayer(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code
    );
    return await refreshGame();
  }

  Future<void> confirmDeath() async {
    await _network.die(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code
    );
    return await refreshGame();
  }

  Future<void> shuffleVictims(bool onlyOutsmartedPlayers) async {
    await _network.shuffleVictims(
      authToken: _account.authToken,
      code: currentGame.code,
      onlyOutsmartedPlayers: onlyOutsmartedPlayers,
    );
    return await refreshGame();
  }
}
