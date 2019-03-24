import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc.dart';

const _gamesStorageKey = 'games';
const _idStorageKey = 'id';
const _nameStorageKey = 'name';
const _currentGameStorageKey = 'current_game';
const _analyticsEnabledKey = 'analytics_enabled';

Future<SharedPreferences> get sp => SharedPreferences.getInstance();

// Storing games.

String _encodeGame(Game game) => json.encode(game);
Game _decodeGame(String encoded) => Game.fromJson(json.decode(encoded));

Future<void> saveGames(List<Game> games) async {
  final encoded = games.map(_encodeGame).toList();
  debugPrint('Saving games: $encoded', wrapWidth: 80);
  await (await sp).setStringList(_gamesStorageKey, encoded);
}

Future<List<Game>> loadGames() async {
  final encoded = (await sp).getStringList(_gamesStorageKey);
  debugPrint('Loaded games: $encoded', wrapWidth: 80);
  final games = <Game>[];
  for (String encodedGame in encoded ?? []) {
    try {
      games.add(_decodeGame(encodedGame));
    } catch (e) {
      // This game is corrupt, so skip it. TODO: log it
    }
  }
  return games;
}

// Storing the id.

Future<void> saveId(String id) async =>
    await (await sp).setString(_idStorageKey, id);
Future<String> loadId() async => await (await sp).getString(_idStorageKey);

// Storing the name.

Future<void> saveName(String name) async =>
    await (await sp).setString(_nameStorageKey, name);
Future<String> loadName() async => await (await sp).getString(_nameStorageKey);

// Storing the current game.

Future<void> saveCurrentGame(String currentGame) async =>
    await (await sp).setString(_currentGameStorageKey, currentGame);
Future<String> loadCurrentGame() async =>
    await (await sp).getString(_currentGameStorageKey);

// Storing whether the user enabled analytics.

Future<void> saveAnalyticsEnabled(bool isEnabled) async =>
    await (await sp).setBool(_analyticsEnabledKey, isEnabled);
Future<bool> loadAnalyticsEnabled() async =>
    await (await sp).getBool(_analyticsEnabledKey) ?? false;
