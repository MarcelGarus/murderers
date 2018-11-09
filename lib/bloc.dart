import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'bloc_provider.dart';
import 'game.dart';
import 'game/game_bloc.dart';
import 'setup/setup_bloc.dart';

export 'game.dart';

/// BLoC.
class MainBloc {
  static const String firebase_root = 'https://us-central1-murderers-e67bb.cloudfunctions.net';

  /// Using this method, any widget in the tree below a BlocHolder can get
  /// access to the bloc.
  static MainBloc of(BuildContext context) {
    final BlocProvider holder = context.ancestorWidgetOfExactType(BlocProvider);
    return holder?.bloc;
  }

  SetupBloc setupBloc = SetupBloc();
  GameBloc gameBloc = GameBloc();

  /// Whether the user knows the game.
  bool _knowsGame = false;

  /// The user's Google Sign In account handler and account.
  final _googleSignIn = GoogleSignIn.standard(
    scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
  );
  GoogleSignInAccount _account;

  /// The firebase cloud messaging service provider.
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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
    print('Initializing the BLoC.');

    setupBloc.initialize(this);
    gameBloc.initialize(this);

    _account = await _googleSignIn.signInSilently();

    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage called: Message is $message.');
      },
      onResume: (msg) async => print('onResume called: Message is $msg.'),
      onLaunch: (msg) async => print('onLaunch called: Message is $msg.'),
    );
    print('Firebase messaging configured.');
  }

  /// Disposes all the streams.
  void dispose() {
    setupBloc.dispose();
    gameBloc.dispose();
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


  /// Registers a game.
  void registerGame(Game game) {
    _game = game;
    _games?.add(_game);
    _gameSubject.add(_game);
    gameBloc.setActiveGame(_game);
  }
}
