import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

export 'game.dart';

/// BLoC.
class Bloc {
  /// Using this method, any widget in the tree below a BlocHolder can get
  /// access to the bloc.
  static Bloc of(BuildContext context) {
    final BlocHolder holder = context.ancestorWidgetOfExactType(BlocHolder);
    return holder?.bloc;
  }

  /// Whether the user knows the game.
  bool _knowsGame = false;

  /// 
  final _googleSignIn = GoogleSignIn.standard(
    scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
  );
  GoogleSignInAccount _account;

  String name;

  /*final account = await GoogleSignIn.standard(
      scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
    ).signIn();

    print(account);*/

  // The streams for communicating with the UI.
  /*final _previousSubject = BehaviorSubject<Comic>();
  final _currentSubject = BehaviorSubject<Comic>();
  final _nextSubject = BehaviorSubject<Comic>();
  final _zoomModeSubject = BehaviorSubject<ZoomStatus>(
    seedValue: ZoomStatus.seed
  );
  Stream<Comic> get previous => _previousSubject.stream.distinct();
  Stream<Comic> get current => _currentSubject.stream.distinct();
  Stream<Comic> get next => _nextSubject.stream.distinct();
  Stream<ZoomStatus> get zoomStatus => _zoomModeSubject.stream; // TODO make distinct*/


  /// Initializes the BLoC.
  void _initialize() async {
    print('Initializing the BLoC.');

    _account = await _googleSignIn.signInSilently();
  }

  /// Disposes all the streams.
  void dispose() {
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
}

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
    bloc.dispose();
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
