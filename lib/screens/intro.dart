import 'package:flutter/material.dart';

import 'setup.dart';
import '../widgets/setup.dart'; // TODO: don't use setup bottom bar

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  TabController controller;
  bool isAtLastSlide = false;

  @override
  void initState() {
    super.initState();

    controller = TabController(length: 3, vsync: this)
    ..addListener(() => setState(() {
      isAtLastSlide = controller.index == controller.length - 1;
    }));
  }

  void _goToNextSlide() {
    if (isAtLastSlide) {
      _goToNextScreen();
    } else {
      controller.animateTo(controller.index + 1);
    }
  }

  void _goToNextScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SetupJourney())
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
              content: 'This game is intended to be played by large groups of '
                'players over a duration of several hours, days or even weeks.',
            ),
            IntroStep(
              image: null,
              title: 'Your destiny: Being a great assassin.',
              content: 'The objective is to "kill" as many players as '
                'possible without getting killed by others. '
                'This app tells you which player to kill - only after you '
                'succeeded, you can proceed to your next victim.'
            ),
            IntroStep(
              image: null,
              title: 'How to kill players',
              content: 'You can "kill" players if they take a physical object '
                'you gave to them. '
                "Right after they took it, tell them they've been killed and "
                'mark your job done in this app.'
            ),
          ],
        )
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: 'Next',
        onPrimary: _goToNextSlide,
        secondary: 'Skip',
        onSecondary: _goToNextScreen
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
