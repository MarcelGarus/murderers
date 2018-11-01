import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'choose_name.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> with TickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();

    controller = TabController(
      length: 4,
      vsync: this,
    );
  }

  void _signIn() async {
    final account = await GoogleSignIn.standard(
      scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
    ).signIn();

    print(account);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: RaisedButton(
          onPressed: _signIn,
          child: Text('The Murderer Game', style: TextStyle(color: Colors.red)),
        ),
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
      bottomNavigationBar: Row(
        children: <Widget>[
          _buildBottomNavigationBarButton(
            text: 'Skip',
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => ChooseName(),
              ));
            }
          ),
          Spacer(),
          _buildBottomNavigationBarButton(text: 'Next', icon: Icon(Icons.keyboard_arrow_right), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBarButton({
    @required String text,
    Widget icon,
    @required VoidCallback onPressed
  }) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      containedInkWell: true,
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(text.toUpperCase()),
            icon ?? Container(height: 0.0)
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
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: <Widget>[
        image ?? Container(height: 200.0, color: Colors.black12),
        SizedBox(height: 32.0),
        Text(title, style: TextStyle(color: Colors.red, fontSize: 20.0)),
        SizedBox(height: 16.0),
        Text(content, textAlign: TextAlign.justify, style: TextStyle(height: 1.1, fontSize: 16.0),),
      ],
    );
  }
}
