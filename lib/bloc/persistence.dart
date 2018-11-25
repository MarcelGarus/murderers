import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'bloc.dart';

const _gamesStorageKey = 'games';

Future<SharedPreferences> get sp => SharedPreferences.getInstance();

// Storing games.

String _encodeGame(Game game) => json.encode(game);
Game _decodeGame(String encoded) => Game.fromJson(json.decode(encoded));

Future<void> saveGames(List<Game> games) async {
  final encoded = games.map(_encodeGame).toList();
  print('Saving games: $encoded');
  (await sp).setStringList(_gamesStorageKey, encoded);
}

Future<List<Game>> loadGames() async {
  final encoded = (await sp).getStringList(_gamesStorageKey);
  print('Loaded games: $encoded');
  return encoded.map(_decodeGame).toList();
}
