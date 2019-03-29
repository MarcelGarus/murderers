import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:pedantic/pedantic.dart';

import '../widgets/button.dart';
import '../widgets/theme.dart';
import 'sign_in.dart';
import 'privacy.dart';

/// The screen which introduces the user to the game concept. In the last step,
/// the user is asked to sign in (using the [SignInScreen]).
class IntroScreen extends StatelessWidget {
  static const numPages = 4;
  final _controller = PageController();

  Future<bool> _onWillPop() async {
    if (_controller.page > 0) {
      unawaited(_controller.previousPage(
        curve: Curves.easeInOutCubic,
        duration: Duration(milliseconds: 200),
      ));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.of(context).backgroundColor,
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
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
                child: _buildBottomBar(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 8, 16, 8),
      child: Row(
        children: <Widget>[
          PageIndicator(
            layout: PageIndicatorLayout.WARM,
            size: 10,
            controller: _controller,
            space: 6,
            count: numPages,
            color: Colors.black26,
            activeColor: MyTheme.of(context).raisedButtonFillColor,
          ),
          Spacer(),
          _NextButton(controller: _controller, numPages: numPages),
        ],
      ),
    );
  }

  Widget _buildContent() {
    var children = <Widget>[
      _IntroStep(
        image: null,
        title: "Welcome to\nThe Murderer Game.",
        content: "A real world game for large groups of players hanging out "
            "for several days.",
      ),
      _IntroStep(
        image: null,
        title: 'Kill players',
        content: "This app tells you who's your victim. Kill it by giving it "
            "a phyiscal object. After you informed your victim about its "
            "death, mark the job as done in this app.",
      ),
      _IntroStep(
        image: null,
        title: 'Be the greatest assassin.',
        content: "Once you killed your victim, you'll get a new one. Try to "
            "kill as many players without dying.",
      ),
      PrivacyScreen(),
    ];

    assert(children.length == numPages);

    return PageView(
      controller: _controller,
      children: children
          .map((step) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16), child: step))
          .toList(),
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
/// and automatically advances its page on click. If the controller already
/// shows the last page, this button automatically disappears.
class _NextButton extends StatefulWidget {
  _NextButton({
    @required this.controller,
    @required this.numPages,
  }) : assert(controller != null);

  final PageController controller;
  final int numPages;

  @override
  __NextButtonState createState() => __NextButtonState();
}

class __NextButtonState extends State<_NextButton> {
  bool get isAcceptButton =>
      (widget.controller.page ?? 0) < (widget.numPages - 1.5);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Button.text(
      (isAcceptButton) ? 'Next' : 'I agree',
      isRaised: false,
      onPressed: () {
        if (isAcceptButton) {
          widget.controller.nextPage(
            curve: Curves.easeInOutCubic,
            duration: Duration(milliseconds: 200),
          );
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => SignInScreen(),
          ));
        }
      },
    );
  }
}
