import 'package:flutter/widgets.dart';

import 'bloc.dart';
import 'game/game_bloc.dart';
import 'setup/setup_bloc.dart';

class BlocProvider extends StatefulWidget {
  BlocProvider({ @required this.child });
  
  final bloc = MainBloc();
  final Widget child;

  _BlocProviderState createState() => _BlocProviderState();
}

class _BlocProviderState extends State<BlocProvider> {
  void initState() {
    super.initState();
    widget.bloc.initialize();
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) => widget.child;
}
