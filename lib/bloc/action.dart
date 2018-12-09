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

Future<void> updateGame(Game game) async {
  final String code = game.code;
  final response = await http.get('${Bloc.firebase_root}/get_game?code=$code');

  if (response.statusCode != 200) {
    print('Something went wrong while updating the game $code.');
    return SetupResult(FunctionStatus.server_corrupt);
  }

  final data = json.decode(response.body);
  print('Updating game with data $data.');

  game.players = (data['players'] as List<dynamic>).map<Player>((playerData) => Player(
    id: playerData['id'],
    name: playerData['name'],
    death: playerData['death']
  )).toList();
}

/// Starts the game.
Future<FunctionStatus> startGame(Game game) async {
  print('Starting game $game');
  final response = await http.get('${Bloc.firebase_root}/start_game?code=${game.code}');

  if (response.statusCode == 403) {
    return FunctionStatus.access_denied;
  } else if (response.statusCode == 404) {
    return FunctionStatus.game_not_found;
  } else if (response.statusCode != 200) {
    // TODO: log somewhere
    print('Unknown server response code: ${response.statusCode}');
    return FunctionStatus.server_corrupt;
  }

  game?.state = GameState.running;

  return FunctionStatus.success;
}

