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
  success,

  /// There's no connection to the internet.
  no_internet,

  /// The server couldn't be found. Maybe it's down or there's restricted
  /// network access.
  no_server,

  /// The connection timed out. Probably, the connection got interrupted or the
  /// network connection is just really bad.
  timeout,

  // The server sent an unexpected response code or content.
  server_corrupt,

  /// The access got denied. Probably the device didn't send a valid Firebase
  /// ID token.
  access_denied,

  /// A game with the given code doesn't exist.
  game_not_found,
}

/// A setup result which contains a status and - if successful - a game.
class SetupResult {
  SetupResult(this.status, [ this.game ]);

  SetupStatus status;
  bool get succeeded => status == SetupStatus.success;

  Game game;
}


/// Does the necessary network stuff to set up a game returns a [SetupResult],
/// which contains a [SetupStatus] and maybe a [Game].
Future<SetupResult> setupGame(SetupConfiguration config, String messagingToken) async {
  assert(config?.role != null);

  switch (config?.role) {
    case UserRole.player: return _joinGame(config, messagingToken);
    case UserRole.watcher: return _watchGame(config, messagingToken);
    case UserRole.creator: return _createGame(config, messagingToken);
  }
  print('Error: Unknown role ${config.role} passed to setupGame.');
  return null;
}

/// Joins a game.
Future<SetupResult> _joinGame(
  SetupConfiguration config,
  String messagingToken
) async {
  assert(config.role == UserRole.player);
  assert(config.code?.length == Game.CODE_LENGTH);

  final String code = config.code;
  final String name = config.playerName;
  final response = await http.get('${Bloc.firebase_root}/join_game?code=$code&name=$name&messagingToken=$messagingToken');

  if (response.statusCode != 200) {
    print('Something went wrong while joining the game $code.');
    return SetupResult(SetupStatus.server_corrupt);
  }

  final data = json.decode(response.body);
  print('Joined game. Data: $data.');

  // Register game in the main bloc.
  final game = Game(
    myRole: UserRole.player,
    code: code,
    name: 'Sample game',
    created: DateTime.now(),
    end: DateTime.now().add(Duration(days: 1)), // TODO: set
    me: Player(
      id: data['id'],
      name: config.playerName
    ),
    authToken: data['authToken']
  );

  return SetupResult(SetupStatus.success, game);
}


/// Creates a new game and registers it in the main bloc.
Future<SetupResult> _createGame(
  SetupConfiguration config,
  String messagingToken
) async {
  assert(config.role == UserRole.creator);
  assert(config.gameName?.isNotEmpty ?? true); // TODO: make sure name exists

  final name = config.gameName;
  final response = await http.get('${Bloc.firebase_root}/create_game?name=$name&messagingToken=$messagingToken');

  if (response.statusCode == 403) {
    return SetupResult(SetupStatus.access_denied);
  } else if (response.statusCode != 200) {
    // TODO: log somewhere, probably in analytics
    print('Unknown server response code: ${response.statusCode}');
    return SetupResult(SetupStatus.server_corrupt);
  }

  // TODO: check if decoding works and game actually contains a 4-char code
  final data = json.decode(response.body);
  print('Game code is ${data['code']}.');
  print('Game is ${data['game']}');
  final code = data['code'];

  // Register game in the main bloc.
  final game = Game(
    myRole: UserRole.creator,
    code: code,
    name: name,
    created: DateTime.now(),
    end: DateTime.now().add(Duration(days: 1)), // TODO: set
  );

  return SetupResult(SetupStatus.success, game);
}


/// Watch a game.
Future<SetupResult> _watchGame(
  SetupConfiguration config,
  String messagingToken
) async {
  return null; // TODO: implement
}
