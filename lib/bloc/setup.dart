/// This library provides the [setupGame] method, which can used to set up
/// games based on a [SetupConfiguration].
/// To allow more meaningful return types, it also provides a [SetupStatus]
/// enum as well as a [SetupResult].

import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

import 'bloc.dart';
import 'function_status.dart';
import 'models/setup.dart';

/// A setup result which contains a status and - if successful - a game.
class SetupResult {
  SetupResult(this.status, [ this.game ]);

  FunctionStatus status;
  bool get succeeded => status == FunctionStatus.success;

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
  // await CloudFunctions.instance.call(functionName: 'join', parameters: { code: code, name: name, messagingToken: messagingToken });

  if (response.statusCode != 200) {
    print('Something went wrong while joining the game $code.');
    return SetupResult(FunctionStatus.server_corrupt);
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

  return SetupResult(FunctionStatus.success, game);
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
    return SetupResult(FunctionStatus.access_denied);
  } else if (response.statusCode != 200) {
    // TODO: log somewhere, probably in analytics
    print('Unknown server response code: ${response.statusCode}');
    return SetupResult(FunctionStatus.server_corrupt);
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

  return SetupResult(FunctionStatus.success, game);
}


/// Watch a game.
Future<SetupResult> _watchGame(
  SetupConfiguration config,
  String messagingToken
) async {
  return null; // TODO: implement
}
