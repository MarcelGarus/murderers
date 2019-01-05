import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'messaging.dart' as messaging;
import 'network.dart' as network;

enum SignInType {
  anonymous,
  google
}

class Handler {
  static String _SHARED_PREFS_ID = 'id';
  static String _SHARED_PREFS_NAME = 'name';

  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn.standard(
    scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
  );
  FirebaseUser _user;
  String _id;
  String _name;
  SharedPreferences _sharedPrefs;

  bool get signedInWithFirebase => _user != null;
  bool get userCreated => _id != null;
  String get name => _name ?? _user?.displayName;
  String get authToken => _user?.uid;


  /// Initializes account on app startup.
  Future<void> initialize() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    _user = await _auth.currentUser();
    _id = _sharedPrefs.getString(_SHARED_PREFS_ID);
    _name = _sharedPrefs.getString(_SHARED_PREFS_NAME);
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
    return signedInWithFirebase;
  }

  /// Signs the user out.
  Future<bool> signOut() async {
    await _auth.signOut();
    _user = null;
    print('Signed out.');
    return !signedInWithFirebase;
  }

  /// Creates a user on the server.
  Future<network.Result<void>> createUser(
    network.Handler networkHandler,
    messaging.Handler messagingHandler,
    String name
  ) async {
    assert(name != null);
    assert(signedInWithFirebase);

    _name = name;
    await _sharedPrefs.setString(_SHARED_PREFS_NAME, name);

    final result = await networkHandler.createUser(
      name: name,
      authToken: authToken,
      messagingToken: await messagingHandler.getToken()
    );

    // If the user creation was successful, save the id.
    if (result.status == network.Status.success) {
      _id = result.data;
      await _sharedPrefs.setString(_SHARED_PREFS_ID, _id);
    }

    return network.Result<void>(result.status);
  }

  /// Renames the user.
  Future<network.Result<void>> rename(
    network.Handler networkHandler,
    String name
  ) async {
    assert(userCreated);

    _name = name;
    await _sharedPrefs.setString(_SHARED_PREFS_NAME, name);
 
    final result = null; // TODO: rename user on the server

    return network.Result<void>(network.Status.success);
  }
}
