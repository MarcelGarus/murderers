import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import '../bloc.dart';
import '../bloc_provider.dart';

class GameBloc {
  /// Setup bloc.
  static const String firebase_root = 'https://us-central1-murderers-e67bb.cloudfunctions.net';

  /// Using this method, any widget in the tree below a [SetupBlocHolder] can get
  /// access to the bloc.
  static GameBloc of(BuildContext context) {
    final BlocProvider provider = context.ancestorWidgetOfExactType(BlocProvider);
    return provider?.bloc?.gameBloc;
  }

  MainBloc _bloc;
  Game _game;

  // The streams for communicating with the UI.
  final _gameSubject = BehaviorSubject<Game>();
  Stream<Game> get game => _gameSubject.stream; //.distinct(); TODO


  void initialize(MainBloc bloc) {
    _bloc = bloc;
  }
  void dispose() {
    _gameSubject.close();
  }


  void setActiveGame(Game game) {
    _game = game;
    print('Active game changed to $_game.');
    _gameSubject.add(_game);
  }
}