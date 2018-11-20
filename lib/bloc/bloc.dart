import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'account.dart';
import 'messaging.dart';
import 'setup.dart' as setup;
import 'bloc_provider.dart';
import 'models/game.dart';
import 'models/setup.dart';

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

  // The handlers for all the specific tasks.
  AccountHandler _account = AccountHandler();
  MessagingHandler _messaging = MessagingHandler();

  /// The user's name.
  String name;

  /// All the games the user participated in. TODO make a list
  List<Game> _games;
  Game _game;

  // The streams for communicating with the UI.
  final _gameSubject = BehaviorSubject<Game>();
  Stream<Game> get game => _gameSubject.stream; //.distinct(); TODO
  

  /// Initializes the BLoC.
  void initialize() async {
    print('Initializing the BLoCs.');

    await _account.initialize();
    await _messaging.initialize();  
  }

  /// Disposes all the streams.
  void dispose() {
    _gameSubject.close();
  }

  bool get isSignedIn => _account.isSignedIn;
  Future<bool> signIn() => _account.signIn();
  Future<void> signOut() => _account.signOut();

  /// Registers a game.
  void registerGame(Game game) {
    _game = game;
    _games?.add(_game);
    _gameSubject.add(_game);
    //gameBloc.setActiveGame(_game);
  }
  void unregisterGame(Game game) {}


  Future<void> setupGame(SetupConfiguration config) async {
    final result = await setup.setupGame(config);
  }

  

  /// Starts the game.
  Future<GameControlResult> startGame() async {
    print('Starting game $_game');
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

    _game?.state = GameState.RUNNING;
    //setActiveGame(_game);

    return GameControlResult.SUCCESS;
  }
}
