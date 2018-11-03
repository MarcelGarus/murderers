import 'package:flutter/material.dart';
import '../game.dart';
import 'confirm_game.dart';
import 'setup_utils.dart';

class ConfigureGameScreen extends StatefulWidget {
  @override
  _ConfigureGameScreenState createState() => _ConfigureGameScreenState();
}

class _ConfigureGameScreenState extends State<ConfigureGameScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SetupAppBar(
            title: 'Configure your game',
            subtitle: 'Adjust everything just like you want it to be',
          ),
          SectionHeader('Game metadata'),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Name", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Give your game a name. This could be the name of the event where this game takes place."),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Code", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("The game code that allows other players to join will be generated when the game is created."),
          ),
          SectionHeader('Joining the game'),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Only signed in players", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Only allow players to join that signed in with their Google account. This allows for easy identity confirmation."),
            trailing: Switch(value: false, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Confirm players", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Once players join, you'll need to approve them before they're actually added to the game."),
            trailing: Switch(value: false, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Joining to running game", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Players that join while the game is running will be added the next time a player gets killed."),
            trailing: Switch(value: false, onChanged: null),
          ),
          SectionHeader('Gameplay'),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Custom rule", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text('You can provide a custom definition of killing. Note that your definition still needs to be legal, so no real killing please.'),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Configure running game", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Do you want to be able to configure the game while it's running? If you do so, you cannot participate, as you'd be able to cheat."),
            trailing: Switch(value: false, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Murder weapon", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Allow players to enter the murder weapon once they're killed."),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Last words", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Allow players to enter their last words once they're killed."),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Publish murderer", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("When a player dies, the murderer's name will be shown to all players. This is a disadvantage for the murderer, if the victim's victim knows the victim was supposed to be his assassin."),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Provide deaths right away", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("All players will get notified as soon as a death occurs."),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("Send out daily summaries", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Send out daily summaries of how many players got killed etc."),
            trailing: Switch(value: true, onChanged: null),
          ),
          SectionHeader('End of the game'),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text("End timestamp", style: TextStyle(fontFamily: 'Signature')),
            subtitle: Text("Provide a specific point in time when the game will end."),
          ),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: "Create game",
        onPrimary: () {
          Navigator.of(context).push(SetupRoute(ConfirmGameScreen(
            role: UserRole.CREATOR,
            code: null,
          )));
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  SectionHeader(this.text);
  
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 4.0),
      child: Text(text,
        style: TextStyle(
          fontFamily: 'Signature',
          color: Theme.of(context).primaryColor
        )
      ),
    );
  }
}
