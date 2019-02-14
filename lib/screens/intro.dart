import 'package:flutter/material.dart';

import '../widgets/button.dart';
import '../widgets/theme.dart';

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

    controller = TabController(length: 4, vsync: this)
    ..addListener(() => setState(() {
      isAtLastSlide = controller.index == controller.length - 1;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('The Murderer Game', style: TextStyle(color: Colors.red)),
        centerTitle: true,
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
            Center(
              child: Button(
                text: 'Sign in',
                onPressed: () {
                  Navigator.of(context).pushNamed('/signin');
                },
              )
            )
          ],
        )
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
    final theme = MyTheme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 300,
          height: 200,
          child: Placeholder(),
        ),
        SizedBox(height: 32),
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(title,
            textAlign: TextAlign.center,
            textScaleFactor: 1.4,
            style: theme.headerText,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Text(content,
            textAlign: TextAlign.center,
            textScaleFactor: 1.1,
            style: theme.bodyText.copyWith(height: 1.1),
          ),
        ),
      ],
    );
  }
}
