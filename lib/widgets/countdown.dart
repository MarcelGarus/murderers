import 'dart:async';

import 'package:flutter/material.dart';

import 'theme.dart';

class Countdown extends StatefulWidget {
  Countdown({
    @required this.target,
  }) : assert(target != null);

  final DateTime target;

  @override
  _CountdownState createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  bool _running = true;

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      setState(() {});
      return _running;
    });
  }

  void dispose() {
    _running = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delta = widget.target.difference(DateTime.now());
    String content;

    if (delta.isNegative) {
      content = 'NOW';
    } else {
      final days = delta.inDays;
      final hours = delta.inHours % 24;
      final minutes = delta.inMinutes % 60;
      final seconds = delta.inSeconds % 60;
      content = (days > 0 ? '${days}d ' : '')
        + (hours > 0 || days > 0 ? '${hours}h ' : '')
        + (minutes > 0 || hours > 0 || days > 0 ? '${minutes}m ' : '')
        + '${seconds}s';
    }

    return Text(content,
      style: MyTheme.of(context).headerText
    );
  }
}
