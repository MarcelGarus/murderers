import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'account.dart' as account;
import 'analytics.dart' as analytics;
import 'network.dart' as network;
import 'messaging.dart' as messaging;
import 'persistence.dart' as persistence;

import 'bloc_provider.dart';
import 'models.dart';
import 'streamed_property.dart';

export 'bloc_provider.dart';
export 'models.dart';
export 'analytics.dart' show AnalyticsEvent;
export 'account.dart' show SignInType;
export 'network.dart'
    show
        NetworkError,
        NoConnectionError,
        BadRequestError,
        ServerCorruptError,
        AuthenticationFailedError,
        ResourceNotFoundError;

/// The BLoC.
class Bloc {
  // The handlers for all the specific tasks.
  final _account = account.Handler();
  final _analytics = analytics.Handler();
  final _network = network.Handler();
  final _messaging = messaging.Handler();

  List<Game> _games = <Game>[];
  final _currentGame = StreamedProperty<Game>();

  /// This method allows subtree widgets to access this bloc.
  static Bloc of(BuildContext context) {
    assert(context != null);
    final BlocProvider holder = context.ancestorWidgetOfExactType(BlocProvider);
    return holder?.bloc;
  }

  /// Initializes the BLoC.
  void initialize() {
    debugPrint('Initializing the BLoC.');

    // Silently sign in asynchronously. Then, asynchronously load the games.
    // TODO: do this in parallel
    _account.initialize().then((_) {
      persistence.loadGames().then((games) async {
        _games = games;
        _games.forEach(_messaging.subscribeToGame);
        if (_games.isNotEmpty) {
          final current = await persistence.loadCurrentGame();
          currentGame = _games.singleWhere((g) => g.code == current);
          await _refreshGame();
        }
      });
    });

    // Asynchronously log app open event.
    _analytics.initialize();

    // Configure the messaging synchronously.
    _messaging.requestNotificationPermissions();
    _messaging.configure(onMessageReceived: () async {
      await _refreshGame();
    });
    _messaging.subscribeToDeaths();
  }

  void dispose() {
    _currentGame.dispose();
  }

  get analyticsEnabled => _analytics.isEnabled;

  set analyticsEnabled(bool isEnabled) {
    assert(isEnabled != null);

    if (isEnabled) {
      _analytics.enable();
    } else {
      _analytics.disable();
    }
  }

  void openPrivacyPolicy() async {
    const url =
        'https://docs.google.com/document/d/1GKn3hvv9OxzLCzdI9gkDNClfoo7lKBIQd4K9unkJumU/edit?usp=sharing';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void logEvent(analytics.AnalyticsEvent event,
      [Map<String, dynamic> parameters]) {
    assert(event != null);

    _analytics.logEvent(event, parameters);
  }

  analytics.RouteObserverProxy get analyticsObserver => _analytics.observer;

  Future<Game> previewGame(String code) async {
    assert(code != null);

    return await _network.getGame(
      id: _account.id,
      authToken: _account.authToken,
      code: code,
    );
  }

  Future<void> signIn(account.SignInType type) async {
    assert(type != null);
    logEvent(analytics.AnalyticsEvent.sign_in_attempt, {'type': type});

    try {
      await _account.signIn(type);
      logEvent(analytics.AnalyticsEvent.sign_in_success);
    } catch (e) {
      logEvent(analytics.AnalyticsEvent.sign_in_failure, {'error': e});
      rethrow;
    }
  }

  Future<bool> signOut() => _account.signOut();

  bool get isSignedIn => _account.isSignedInWithFirebase;

  Future<void> createAccount({@required String name}) async {
    assert(name != null);

    return await _account.createUser(
      networkHandler: _network,
      messagingHandler: _messaging,
      name: name,
    );
  }

  // TODO: removes an account.

  bool get hasAccount => _account.userWasCreated;

  String get name => _account.name;

  set name(String name) {
    assert(
        name != null,
        "The name cannot be null. If you want to delete the "
        "account, consider calling removeAccount.");

    // TODO: handle result
    _account.rename(networkHandler: _network, name: name);
  }

  String get accountPhotoUrl => _account.photoUrl;

  List<Game> get allGames => List.unmodifiable(_games);

  Game get currentGame => _currentGame.value;

  set currentGame(Game game) {
    assert(game == null || _games.contains(game));
    debugPrint("Setting current game to $game", wrapWidth: 80);

    _currentGame.value = game;
    persistence.saveCurrentGame(game?.code ?? '');
  }

  bool get hasCurrentGame => currentGame != null;

  get currentGameStream => _currentGame.stream;

  Future<Game> watchGame(String code) async {
    assert(code != null);

    // TODO: implement
    return null;
  }

  Future<Game> joinGame(String code) async {
    assert(code != null);
    assert(_account.userWasCreated);

    final existingGame = _games.singleWhere((game) => game.code == code);
    if (existingGame?.isPlayer ?? false) {
      return existingGame;
    }

    await _network.joinGame(
      id: _account.id,
      authToken: _account.authToken,
      code: code,
    );
    return await _network
        .getGame(
          id: _account.id,
          authToken: _account.authToken,
          code: code,
        )
        .then(_addGame);
  }

  Future<Game> createGame({
    @required String name,
    @required DateTime start,
    @required DateTime end,
  }) async {
    assert(name != null);
    assert(start != null);
    assert(end != null);
    assert(hasAccount);

    return await _network
        .createGame(
            id: _account.id,
            authToken: _account.authToken,
            name: name,
            start: start,
            end: end)
        .then(_addGame);
  }

  // Adds a game to the list of games.
  Future<Game> _addGame(Game game) async {
    assert(game != null);

    _games
      ..removeWhere((g) => g.code == game.code)
      ..add(game);
    currentGame = game;
    await persistence.saveGames(_games);
    return game;
  }

  // TODO: if we're a player or creator, deny or notify server.
  void removeGame(Game game) async {
    assert(game != null);

    _games.remove(game);
    if (!_games.contains(currentGame)) {
      currentGame = _games.isEmpty ? null : _games.first;
    }
    await persistence.saveGames(_games);
  }

  // Updates the current game to the new game.
  void _updateCurrentGame(Game game) async {
    _games.remove(currentGame);
    _games.add(game);
    currentGame = game;
    await persistence.saveGames(_games);
  }

  // Refreshes the current game.
  Future<Game> _refreshGame() async {
    final game = await _network.getGame(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code,
    );
    logEvent(analytics.AnalyticsEvent.game_loaded, {'code': game.code});
    _updateCurrentGame(game);
    return game;
  }

  Future<void> acceptPlayers({@required List<Player> players}) async {
    assert(players != null);
    assert(players.isNotEmpty);

    await _network.acceptPlayer(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code,
      players: players,
    );
    await _refreshGame();
  }

  Future<void> startGame() async {
    await _network.startGame(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code,
    );
    await _refreshGame();
  }

  Future<void> killPlayer() async {
    await _network.killPlayer(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code,
      victim: currentGame.victim.id,
    );
    await _refreshGame();
  }

  Future<void> confirmDeath({
    @required String weapon,
    @required String lastWords,
  }) async {
    assert(weapon != null);
    assert(lastWords != null);

    await _network.die(
      id: _account.id,
      authToken: _account.authToken,
      code: currentGame.code,
      weapon: weapon,
      lastWords: lastWords,
    );
    await _refreshGame();
  }

  Future<void> shuffleVictims({@required bool onlyOutsmartedPlayers}) async {
    assert(onlyOutsmartedPlayers != null);

    await _network.shuffleVictims(
      authToken: _account.authToken,
      code: currentGame.code,
      onlyOutsmartedPlayers: onlyOutsmartedPlayers,
    );
    await _refreshGame();
  }
}
