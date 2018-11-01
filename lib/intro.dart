import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'bottom_bar.dart';
import 'log_in.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();

    controller = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('The Murderer Game', style: TextStyle(color: Colors.red)),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: controller,
          children: <Widget>[
            IntroStep(
              image: null,
              title: "Who's this game for?",
              content: "This game is intended to be played by large groups of "
                "players over a duration of several hours, days or even weeks.",
            ),
            IntroStep(
              image: null,
              title: "How the game works",
              content: "The objective is to \"kill\" as many other players as "
                "possible in the set amount of time without getting killed by "
                "others. "
                "You can \"kill\" players if they take a physical object you "
                "passed to them. "
                "This app tells you which player to kill - only after you "
                "succeeded, you can proceed to the next victim. And yes, it's "
                "okay to feel like an assassin."
            ),
          ],
        )
      ),
      bottomNavigationBar: BottomBar(
        primary: 'Next',
        secondary: 'Skip',
        onPrimary: () {},
        onSecondary: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LogInScreen(),
          ));
        }
      ),
    );
  }
}

class IntroStep extends StatelessWidget {
  IntroStep({
    @required this.image,
    @required this.title,
    @required this.content,
  });

  final Image image;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: <Widget>[
        image ?? Material(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8.0),
          child: Container(height: 200.0),
        ),
        SizedBox(height: 32.0),
        Text(title, style: TextStyle(fontFamily: 'Signature', color: Colors.red, fontSize: 20.0)),
        SizedBox(height: 16.0),
        Text(content, textAlign: TextAlign.justify, style: TextStyle(height: 1.1, fontSize: 16.0),),
      ],
    );
  }
}
