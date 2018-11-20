import 'package:flutter/widgets.dart';

import 'bloc.dart';

/// The generic bloc provider implemented by the specialized bloc providers
/// above.
class BlocProvider extends StatefulWidget {
  BlocProvider({ @required this.child });
  
  final Bloc bloc = Bloc();
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
