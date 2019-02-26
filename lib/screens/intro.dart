import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';

import '../widgets/button.dart';
import '../widgets/theme.dart';
import 'sign_in.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Villain(
          villainAnimation: VillainAnimation.fromTop(
            offset: 1,
            curve: Curves.easeOutCubic,
          ),
          child: Text('The Murderer Game', style: TextStyle(color: Colors.red)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Villain(
                villainAnimation: VillainAnimation.transformTranslate(
                  fromOffset: Offset(0, 30),
                  curve: Curves.easeOutCubic,
                  to: Duration(milliseconds: 200),
                ),
                secondaryVillainAnimation: VillainAnimation.fade(),
                child: _buildContent(),
              ),
            ),
            Villain(
              villainAnimation: VillainAnimation.fromBottom(
                relativeOffset: 1,
                curve: Curves.easeOutCubic,
              ),
              child: _buildBottomBar(),
            ),
          ],
        )
      ),
    );
  }

  Padding _buildBottomBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 8, 16, 16),
      child: Row(
        children: <Widget>[
          TabPageSelector(controller: _controller),
          Spacer(),
          Button.text('Next',
            isRaised: false,
            onPressed: () {
              if (_controller.index < _controller.length - 1) {
                _controller.index++;
              }
            },
          ),
        ],
      ),
    );
  }

  TabBarView _buildContent() {
    return TabBarView(
      controller: _controller,
      children: <Widget>[
        IntroStep(
          image: null,
          title: "Welcome to\nThe Murderer Game.",
          content: 'A real world game for large groups of players '
            'hanging out for several days.',
        ),
        IntroStep(
          image: null,
          title: 'Kill players',
          content: "This app tells you who's your victim. Kill it by "
            "giving it a phyiscal object. After you informed your "
            "victim about its death, mark the job as done in this app."
        ),
        IntroStep(
          image: null,
          title: 'Be the greatest assassin.',
          content: "Once you killed your victim, you'll get a new "
            "one. Try to kill as many players without dying."
        ),
        SignInScreen(),
      ].map(
        (step) => Padding(padding: EdgeInsets.all(32), child: step)
      ).toList(),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(height: 200, child: Placeholder()),
        SizedBox(height: 32),
        Text(title, style: theme.headerText),
        SizedBox(height: 16),
        Text(content, style: theme.bodyText.copyWith(height: 1.1)),
      ],
    );
  }
}
