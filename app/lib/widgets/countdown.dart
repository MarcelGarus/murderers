import 'dart:async';

import 'package:flutter/material.dart';

import 'theme.dart';

class Countdown extends StatefulWidget {
  const Countdown({
    @required this.target,
  }) : assert(target != null);

  final DateTime target;

  @override
  _CountdownState createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  var _running = true;

  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {
      setState(() {});
      await Future.delayed(Duration(milliseconds: 500));
      return _running;
    });
  }

  @override
  void dispose() {
    _running = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var delta = widget.target.difference(DateTime.now());
    String content;

    if (delta.isNegative) {
      content = 'NOW';
    } else {
      final days = delta.inDays;
      final hours = delta.inHours % 24;
      final minutes = delta.inMinutes % 60;
      final seconds = delta.inSeconds % 60;
      content = (days > 0 ? '${days}d ' : '') +
          (hours > 0 || days > 0 ? '${hours}h ' : '') +
          (minutes > 0 || hours > 0 || days > 0 ? '${minutes}m ' : '') +
          '${seconds}s';
    }

    return Text(content, style: MyTheme.of(context).headerText);
  }
}
