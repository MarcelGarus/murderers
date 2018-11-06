import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'game.dart';

export 'game.dart';

/// BLoC.
class Bloc {
  static const String firebase_root = 'https://us-central1-murderers-e67bb.cloudfunctions.net';

  /// Using this method, any widget in the tree below a BlocHolder can get
  /// access to the bloc.
  static Bloc of(BuildContext context) {
    final BlocHolder holder = context.ancestorWidgetOfExactType(BlocHolder);
    return holder?.bloc;
  }

  /// Whether the user knows the game.
  bool _knowsGame = false;

  /// The user's Google Sign In account handler and account.
  final _googleSignIn = GoogleSignIn.standard(
    scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
  );
  GoogleSignInAccount _account;

  /// The user's name.
  String name;

  /// All the games the user participated in.
  final games = <Game>[];

  // The streams for communicating with the UI.
  final _gameSubject = BehaviorSubject<Game>();
  Stream<Game> get game => _gameSubject.stream; //.distinct(); TODO
  

  /// Initializes the BLoC.
  void _initialize() async {
    print('Initializing the BLoC.');

    _account = await _googleSignIn.signInSilently();
  }

  /// Disposes all the streams.
  void _dispose() {
    _gameSubject.close();
  }

  /// Signs the user into Google.
  Future<bool> signIn() async {
    _account = await _googleSignIn.signIn();
    name ??= _account?.displayName;
    print('Signed in: $_account');
    return _account != null;
  }

  /// Signs the user out of Google.
  Future<void> signOut() async {
    _account = await _googleSignIn.signOut();
    print('Signed out: $_account');
  }

  /// Returns whether the user is signed into Google.
  bool get isSignedIn => _account != null;

  /// Creates a new game.
  Future<Game> createGame() async {
    final response = await http.get('$firebase_root/create_game');

    if (response.statusCode != 200) {
      print('Something went wrong while creating a game.');
      return null;
    }

    final data = json.decode(response.body);
    print('Game code is ${data['code']}.');
    print('Game is ${data['game']}');
    return null; // TODO: construct game
  }

  /// Joins a game.
  Future<Game> joinGame(String code) async {
    final response = await http.get('$firebase_root/join_game?code=$code');

    if (response.statusCode != 200) {
      print('Something went wrong while joining the game $code.');
      return null;
    }

    final data = json.decode(response.body);
    print('Data: $data.');
    return null; // TODO: construct game
  }
}


// The code below is just for properly managing the BLoC state.

class BlocProvider extends StatefulWidget {
  BlocProvider({ @required this.child });
  
  final Widget child;

  _BlocProviderState createState() => _BlocProviderState();
}

class _BlocProviderState extends State<BlocProvider> {
  final Bloc bloc = Bloc();

  void initState() {
    super.initState();
    bloc._initialize();
  }

  @override
  void dispose() {
    bloc._dispose();
    super.dispose();
  }

  Widget build(BuildContext context) => BlocHolder(bloc, widget.child);
}

class BlocHolder extends StatelessWidget {
  BlocHolder(this.bloc, this.child);
  
  final Bloc bloc;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
