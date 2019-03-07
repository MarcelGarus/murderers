import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';
import '../widgets/theme.dart';
import 'sign_in.dart';

/// The screen which introduces the user to the game concept. In the last step,
/// the user is asked to sign in (using the [SignInScreen]).
class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    Bloc.of(context).logEvent(AnalyticsEvent.intro_begin);
    _controller = TabController(length: 4, vsync: this);
    _controller.animation.addListener(() {
      if (_controller.indexIsChanging) {
        Bloc.of(context).logEvent(AnalyticsEvent.intro_step, {
          'step': _controller.index
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.of(context).backgroundColor,
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

  Widget _buildBottomBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 8, 16, 8),
      child: Row(
        children: <Widget>[
          TabPageSelector(controller: _controller),
          Spacer(),
          _NextButton(controller: _controller),
        ],
      ),
    );
  }

  TabBarView _buildContent() {
    return TabBarView(
      controller: _controller,
      children: <Widget>[
        _IntroStep(
          image: null,
          title: "Welcome to\nThe Murderer Game.",
          content: 'A real world game for large groups of players '
            'hanging out for several days.',
        ),
        _IntroStep(
          image: null,
          title: 'Kill players',
          content: "This app tells you who's your victim. Kill it by "
            "giving it a phyiscal object. After you informed your "
            "victim about its death, mark the job as done in this app."
        ),
        _IntroStep(
          image: null,
          title: 'Be the greatest assassin.',
          content: "Once you killed your victim, you'll get a new "
            "one. Try to kill as many players without dying."
        ),
        SignInScreen(),
      ].map((step) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: step
      )).toList(),
    );
  }
}

/// A single step in the introductory course. Has an [image], [title] and
/// [content].
class _IntroStep extends StatelessWidget {
  _IntroStep({
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

/// The next button on the bottom of the screen. Adapts to a [TabController] and
/// and automatically advances its index on click. If the controller already
/// shows the last page, this button automatically disappears.
class _NextButton extends StatelessWidget {
  _NextButton({
    @required this.controller,
  }) : assert(controller != null);
  
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animation,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: (controller.index < controller.length - 1) ? 1 : 0,
          duration: Duration(milliseconds: 200),
          child: child,
        );
      },
      child: Button.text('Next',
        isRaised: false,
        onPressed: () {
          if (controller.index < controller.length - 1) {
            controller.index++;
          }
        },
      )
    );
  }
}
