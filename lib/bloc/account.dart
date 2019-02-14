import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'messaging.dart' as messaging;
import 'network.dart' as network;
import 'persistence.dart' as persistence;

enum SignInType {
  anonymous,
  google
}

class Handler {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn.standard(
    scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
  );
  FirebaseUser _user;
  String _id;
  String _name;

  bool get isSignedInWithFirebase => _user != null;
  bool get userWasCreated => _id != null;
  String get name => _name ?? _user?.displayName;
  String get id => _id;
  String get authToken => _user?.uid;


  /// Initializes account on app startup.
  Future<void> initialize() async {
    _user = await _auth.currentUser();
    _id = await persistence.loadId();
    _name = await persistence.loadName();
  }

  /// Signs in the user.
  Future<bool> signIn(SignInType type) async {
    switch (type) {
      case SignInType.anonymous:
        _user = await _auth.signInAnonymously();
        break;
      case SignInType.google:
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser.authentication;
        _user = await _auth.signInWithGoogle(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
        );
        break;
    }
    print('Signed in: $_user');
    return isSignedInWithFirebase;
  }

  /// Signs the user out.
  Future<bool> signOut() async {
    await _auth.signOut();
    _user = null;
    print('Signed out.');
    return !isSignedInWithFirebase;
  }

  /// Creates a user on the server.
  Future<void> createUser(
    network.Handler networkHandler,
    messaging.Handler messagingHandler,
    String name
  ) async {
    assert(name != null);
    assert(isSignedInWithFirebase);

    _name = name;
    await persistence.saveName(name);

    final id = await networkHandler.createUser(
      name: name,
      authToken: authToken,
      messagingToken: await messagingHandler.getToken()
    );

    // If the user creation was successful, save the id.
    _id = id;
    await persistence.saveId(_id);
  }

  /// Renames the user.
  Future<void> rename(
    network.Handler networkHandler,
    String name
  ) async {
    assert(userWasCreated);

    _name = name;
    await persistence.saveName(name);
 
    // TODO: rename user on the server
    //final result = null;
  }
}
