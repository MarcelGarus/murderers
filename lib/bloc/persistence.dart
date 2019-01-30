import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'bloc.dart';

const _gamesStorageKey = 'games';
const _idStorageKey = 'id';
const _nameStorageKey = 'name';
const _currentGameStorageKey = 'current_game';

Future<SharedPreferences> get sp => SharedPreferences.getInstance();

// Storing games.

String _encodeGame(Game game) => json.encode(game);
Game _decodeGame(String encoded) => Game.fromJson(json.decode(encoded));

Future<void> saveGames(List<Game> games) async {
  final encoded = games.map(_encodeGame).toList();
  print('Saving games: $encoded');
  await (await sp).setStringList(_gamesStorageKey, encoded);
}

Future<List<Game>> loadGames() async {
  final encoded = (await sp).getStringList(_gamesStorageKey);
  print('Loaded games: $encoded');
  return encoded.map(_decodeGame).toList();
}

// Storing the id.

Future<void> saveId(String id) async => await (await sp).setString(_idStorageKey, id);
Future<String> loadId() async => await (await sp).getString(_idStorageKey);

// Storing the name.

Future<void> saveName(String name) async => await (await sp).setString(_nameStorageKey, name);
Future<String> loadName() async => await (await sp).getString(_nameStorageKey);

// Storing the current game.

Future<void> saveCurrentGame(String currentGame) async => await (await sp).setString(_currentGameStorageKey, currentGame);
Future<String> loadCurrentGame() async => await (await sp).getString(_currentGameStorageKey);
