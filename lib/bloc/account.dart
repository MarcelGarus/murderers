import 'package:google_sign_in/google_sign_in.dart';

class Handler {
  // The Google sign in provider.
  final _googleSignIn = GoogleSignIn.standard(
    scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
  );

  /// The user's account.
  GoogleSignInAccount _account;
  GoogleSignInAccount get account => _account;
  bool get isSignedIn => _account != null;

  Future<void> initialize() async {
    _account = await _googleSignIn.signInSilently();
  }

  /// Signs the user into Google.
  Future<bool> signIn() async {
    _account = await _googleSignIn.signIn();
    print('Signed in: $_account');
    return isSignedIn;
  }

  /// Signs the user out of Google.
  Future<void> signOut() async {
    _account = await _googleSignIn.signOut();
    print('Signed out: $_account');
    return !isSignedIn;
  }
}
