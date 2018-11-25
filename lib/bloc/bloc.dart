import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'account.dart' as account;
import 'messaging.dart' as messaging;
import 'persistence.dart' as persistence;
import 'setup.dart' as setup;

import 'bloc_provider.dart';
import 'models/game.dart';
import 'models/setup.dart';
import 'streamed_property.dart';

export 'bloc_provider.dart';
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
  // TODO: use the cloud function package
  static const String firebase_root = 'https://us-central1-murderers-e67bb.cloudfunctions.net';

  /// This methods allows subtree widgets to access this bloc.
  static Bloc of(BuildContext context) {
    final BlocProvider holder = context.ancestorWidgetOfExactType(BlocProvider);
    return holder?.bloc;
  }

  /// Whether the user knows the game.
  bool _knowsGame = false;

  /// Whether the user enabled notifications.
  bool _notificationsEnabled = false;

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
  void initialize() async {
    print('Initializing the BLoC.');

    _games = await persistence.loadGames();
    if (_games.isNotEmpty) {
      activeGame = _games.first;
    }

    await _account.initialize();

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


  Future<setup.SetupResult> setupGame(SetupConfiguration config) async {
    final messagingToken = await _messaging.getToken();
    final result = await setup.setupGame(config, messagingToken);
    if (result.status == setup.SetupStatus.success) {
      addGame(result.game);
    }
    return result;
  }

  

  /// Starts the game.
  Future<GameControlResult> startGame() async {
    print('Starting game $_activeGame');
    final response = await http.get('$firebase_root/start_game');

    if (response.statusCode == 403) {
      return GameControlResult.ACCESS_DENIED;
    } else if (response.statusCode == 404) {
      return GameControlResult.GAME_NOT_FOUND;
    } else if (response.statusCode != 200) {
      // TODO: log somewhere
      print('Unknown server response code: ${response.statusCode}');
      return GameControlResult.SERVER_CORRUPT;
    }

    activeGame?.state = GameState.running;
    //setActiveGame(_game);

    return GameControlResult.SUCCESS;
  }
}
