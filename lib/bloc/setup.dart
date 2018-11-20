/// This library provides the [setupGame] method, which can used to set up
/// games based on a [SetupConfiguration].
/// To allow more meaningful return types, it also provides a [SetupStatus]
/// enum as well as a [SetupResult].

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'bloc.dart';
import 'models/setup.dart';

/// These are all possible setup statuses that the [SetupResult] can contain.
/// Note that depending on how the game is set up, not necessarily all of them
/// can occur.
enum SetupStatus {
  /// The game was successfully set up.
  SUCCESS,

  /// There's no connection to the internet.
  NO_INTERNET,

  /// The server couldn't be found. Maybe it's down or there's restricted
  /// network access.
  NO_SERVER,

  /// The connection timed out. Probably, the connection got interrupted or the
  /// network connection is just really bad.
  TIMEOUT,

  // The server sent an unexpected response code or content.
  SERVER_CORRUPT,

  /// The access got denied. Probably the device didn't send a valid Firebase
  /// ID token.
  ACCESS_DENIED,

  /// A game with the given code doesn't exist.
  GAME_NOT_FOUND,
}

/// A setup result which contains a status and - if the status is
/// [SetupStatus.SUCCESS] - a game.
class SetupResult {
  SetupResult(this.status, [ this.game ]);

  SetupStatus status;
  bool get succeeded => status == SetupStatus.SUCCESS;

  Game game;
}


/// Does the necessary network stuff to set up a game returns a [SetupResult],
/// which contains a [SetupStatus] and maybe a [Game].
Future<SetupResult> setupGame(SetupConfiguration config) async {
  assert(config?.role != null);

  switch (config?.role) {
    case UserRole.PLAYER: return _joinGame(config);
    case UserRole.WATCHER: return _watchGame(config);
    case UserRole.CREATOR: return _createGame(config);
  }
  print('Error: Unknown role ${config.role} passed to setupGame.');
  return null;
}

/// Joins a game.
Future<SetupResult> _joinGame(SetupConfiguration config) async {
  assert(config.role == UserRole.PLAYER);
  assert(config.code?.length == Game.CODE_LENGTH);

  final String code = config.code;
  final response = await http.get('${Bloc.firebase_root}/join_game?code=$code');

  if (response.statusCode != 200) {
    print('Something went wrong while joining the game $code.');
    return SetupResult(SetupStatus.SERVER_CORRUPT);
  }

  final data = json.decode(response.body);
  print('Joined game. Data: $data.');

  // Register game in the main bloc.
  final game = Game(
    myRole: UserRole.PLAYER,
    code: code,
    name: 'Sample game',
    created: DateTime.now(),
    end: DateTime.now().add(Duration(days: 1)), // TODO: set
  );

  return SetupResult(SetupStatus.SUCCESS, game);
}


/// Creates a new game and registers it in the main bloc.
Future<SetupResult> _createGame(SetupConfiguration config) async {
  final response = await http.get('${Bloc.firebase_root}/create_game');

  if (response.statusCode == 403) {
    return SetupResult(SetupStatus.ACCESS_DENIED);
  } else if (response.statusCode != 200) {
    // TODO: log somewhere, probably in analytics
    print('Unknown server response code: ${response.statusCode}');
    return SetupResult(SetupStatus.SERVER_CORRUPT);
  }

  // TODO: check if decoding works and game actually contains a 4-char code
  final data = json.decode(response.body);
  print('Game code is ${data['code']}.');
  print('Game is ${data['game']}');
  final code = data['code'];

  // Register game in the main bloc.
  final game = Game(
    myRole: UserRole.CREATOR,
    code: code,
    name: 'Sample game',
    created: DateTime.now(),
    end: DateTime.now().add(Duration(days: 1)), // TODO: set
  );

  return SetupResult(SetupStatus.SUCCESS, game);
}


/// Watch a game.
Future<SetupResult> _watchGame(SetupConfiguration config) async {
  return null; // TODO: implement
}
