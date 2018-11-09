import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../bloc.dart';
import '../bloc_provider.dart';
import '../game.dart';

export '../game.dart';

enum GameSetupResult { SUCCESS, ACCESS_DENIED, SERVER_CORRUPT } // TODO: add NO_INTERNET, TIMEOUT

/// Setup bloc.
class SetupBloc {
  static const String firebase_root = 'https://us-central1-murderers-e67bb.cloudfunctions.net';

  /// Using this method, any widget in the tree below a [SetupBlocHolder] can get
  /// access to the bloc.
  static SetupBloc of(BuildContext context) {
    final BlocProvider provider = context.ancestorWidgetOfExactType(BlocProvider);
    return provider?.bloc?.setupBloc;
  }

  MainBloc _bloc;

  // User and basic information.
  UserRole role;
  String name;
  String code; // Game code

  bool get canCreateNewGame => _bloc.isSignedIn;


  void initialize(MainBloc bloc) {
    _bloc = bloc;
  }
  void dispose() {}


  /// Joins a game.
  Future<GameSetupResult> joinGame(String code) async {
    final response = await http.get('$firebase_root/join_game?code=$code');

    if (response.statusCode != 200) {
      print('Something went wrong while joining the game $code.');
      return GameSetupResult.SERVER_CORRUPT;
    }

    final data = json.decode(response.body);
    print('Data: $data.');
    return GameSetupResult.SUCCESS; // TODO: construct game
  }


  /// Creates a new game and registers it in the main bloc.
  Future<GameSetupResult> createGame() async {
    final response = await http.get('$firebase_root/create_game');

    if (response.statusCode == 403) {
      return GameSetupResult.ACCESS_DENIED;
    } else if (response.statusCode != 200) {
      // TODO: log somewhere
      print('Unknown server response code: ${response.statusCode}');
      return GameSetupResult.SERVER_CORRUPT;
    }

    // TODO: check if decoding works and game actually contains a 4-char code
    final data = json.decode(response.body);
    print('Game code is ${data['code']}.');
    print('Game is ${data['game']}');
    final code = data['code'];

    // Register game in the main bloc.
    _bloc.registerGame(Game(
      myRole: UserRole.CREATOR,
      code: code,
      name: 'Sample game',
      created: DateTime.now(),
      end: DateTime.now().add(Duration(days: 1)), // TODO: set
    ));

    return GameSetupResult.SUCCESS;
  }


  /// Watch a game.
  Future<bool> watchGame() async {
    return false;
  }
}
