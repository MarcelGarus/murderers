import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import 'messaging.dart' as messaging;
import 'network.dart' as network;
import 'persistence.dart' as persistence;

enum SignInType { anonymous, google }

class Handler {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn.standard(
      scopes: ['email', 'https://www.googleapis.com/auth/drive.appdata']);
  FirebaseUser _user;
  String _id;
  String _name;

  bool get isSignedInWithFirebase => _user != null;
  bool get userWasCreated => _id != null;
  String get name => _name ?? _user?.displayName;
  String get id => _id;
  String get authToken => _user?.uid;
  String get photoUrl => _user.photoUrl;

  /// Initializes account on app startup.
  Future<void> initialize() async {
    _user = await _auth.currentUser();
    _id = await persistence.loadId();
    _name = await persistence.loadName();

    debugPrint(
      'Account initialized. $_name with id $_id has auth token $authToken',
      wrapWidth: 80,
    );
  }

  /// Signs in the user.
  Future<void> signIn(SignInType type) async {
    switch (type) {
      case SignInType.anonymous:
        _user = await _auth.signInAnonymously();
        break;
      case SignInType.google:
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser?.authentication;
        if (googleAuth == null) {
          throw StateError('Signing in failed due to aborting.');
        }
        _user = await _auth.signInWithGoogle(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        break;
    }
    if (!isSignedInWithFirebase) {
      throw StateError('Signing in failed due to unknown reasons.');
    }
  }

  /// Signs the user out.
  Future<bool> signOut() async {
    await _auth.signOut();

    _user = null;
    _id = null;
    _name = null;

    await persistence.saveId(_id);
    await persistence.saveName(_name);

    debugPrint('Signed out.');
    return !isSignedInWithFirebase;
  }

  /// Creates a user on the server.
  Future<void> createUser(
      {@required network.Handler networkHandler,
      @required messaging.Handler messagingHandler,
      @required String name}) async {
    assert(networkHandler != null);
    assert(messagingHandler != null);
    assert(name != null);
    assert(isSignedInWithFirebase);

    _name = name;
    await persistence.saveName(name);

    var id = await networkHandler.createUser(
        name: name,
        authToken: authToken,
        messagingToken: await messagingHandler.getToken());

    // If the user creation was successful, save the id.
    _id = id;
    await persistence.saveId(_id);
  }

  /// Renames the user.
  Future<void> rename(
      {@required network.Handler networkHandler, @required String name}) async {
    assert(networkHandler != null);
    assert(name != null);
    assert(userWasCreated);

    if (_name == name) return;

    _name = name;
    await persistence.saveName(name);

    // TODO: rename user on the server
    //final result = null;
  }
}
