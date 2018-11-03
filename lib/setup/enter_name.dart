import 'package:flutter/material.dart';
import '../bloc.dart';
import 'setup_finished.dart';
import 'setup_utils.dart';

class EnterNameScreen extends StatefulWidget {
  EnterNameScreen({
    @required this.role,
    @required this.code,
  });

  final UserRole role;
  final String code;

  @override
  _EnterNameScreenState createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SetupAppBar(
            title: "What's your name?",
          ),
          SizedBox(height: 24.0),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Enter first and last name",
            ),
          ),
          SizedBox(height: 16.0),
          Text('Other players will be able to see it. To counter confusion in large groups, it\'s recommended to enter both your first and last name.'),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: 'Done',
        onPrimary: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SetupFinishedScreen(
              role: widget.role,
              code: widget.code
            )
          ));
        },
      ),
    );
  }
}
