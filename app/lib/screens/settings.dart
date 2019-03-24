import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';
import '../widgets/theme.dart';

void _displayNotImplementedSnackbar(BuildContext context) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text('Not implemented yet.'),
  ));
}

class SettingsScreen extends StatefulWidget {
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget build(BuildContext context) {
    var theme = kThemeLight;
    return MyTheme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: theme.raisedButtonFillColor,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _ProfileSettings(),
            SizedBox(height: 16),
            _GameSettings(),
            SizedBox(height: 16),
            _NotificationSettings(),
            SizedBox(height: 16),
            _PrivacySettings(),
            SizedBox(height: 16),
            _About(),
          ],
        ),
      ),
    );
  }
}

class _ProfileSettings extends StatelessWidget {
  Widget build(BuildContext context) {
    final theme = MyTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.black12,
            backgroundImage: NetworkImage(Bloc.of(context).accountPhotoUrl),
            radius: 32,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Signed in as ${Bloc.of(context).name}.",
                  style: theme.bodyText.copyWith(fontSize: 24),
                ),
                SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Button.text('Edit name',
                      onPressed: () => _displayNotImplementedSnackbar(context),
                      isRaised: false,
                    ),
                    SizedBox(width: 8),
                    Button.text('Sign out',
                      onPressed: Bloc.of(context).signOut,
                      isRaised: false,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _GameSettings extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: Bloc.of(context).allGames.map<Widget>((game) {
        return ListTile(
          title: Text(game.name),
        );
      }).followedBy([Container(height:8,color:Colors.pink)]).toList(),
    );
  }
}

class _NotificationSettings extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildCheckbox(
          context: context,
          value: true,
          label: 'Receive notifications when someone kills you.',
        ),
        _buildCheckbox(
          context: context,
          value: true,
          onChanged: (_) => _displayNotImplementedSnackbar(context),
          label: 'Receive notifications when someone joins your game.',
        ),
        _buildCheckbox(
          context: context,
          value: true,
          onChanged: (_) => _displayNotImplementedSnackbar(context),
          label: 'Receive notifications when someone in your game gets killed.',
        ),
      ],
    );
  }
}

class _PrivacySettings extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          "The backend of this app runs on Google's servers. That means, some "
          "information about your device as well as the actions you take "
          "inside the app are sent to Google."
        ),
        _buildCheckbox(
          context: context,
          value: true,
          onChanged: (_) => _displayNotImplementedSnackbar(context),
          label: "Provide analytics data, like device information and how you "
            "interact with the app to make the app better."
        ),
        Button.text('Read the privacy policy',
          isRaised: false,
          onPressed: () {
            Bloc.of(context).openPrivacyPolicy();
          },
        ),
      ],
    );
  }
}

class _About extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlutterLogo(),
        SizedBox(height: 16),
        Text(
          "This app was built with Flutter.\n"
          "It is open source. Feel free to contribute on Github.",
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Button.text(
          'Open Github repository',
          onPressed: () {
            const url = 'https://www.github.com/marcelgarus/murderers';
            () async {
              if (await canLaunch(url)) {
                await launch(url);
              }
            }();
          },
          isRaised: false,
        ),
        SizedBox(height: 16),
        _buildNames(context, 'Developer', [
          'Marcel Garus',
        ]),
        _buildNames(context, 'Testers', [
          'TODO: make sure they are okay with being listed here',
          'Marcel Garus',
        ]),
      ],
    );
  }

  Widget _buildNames(BuildContext context, String title, List<String> names) {
    var theme = MyTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title,
          style: theme.bodyText.copyWith(color: Colors.red, fontFamily: 'Signature'),
        ),
        SizedBox(height: 8),
        Text(names.join('\n'),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

Widget _buildCheckbox({
  @required BuildContext context,
  @required bool value,
  void Function(bool newValue) onChanged,
  @required String label,
}) {
  var theme = MyTheme.of(context);
  return Row(
    children: <Widget>[
      Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: theme.flatButtonColor
      ),
      Expanded(child: Text(label, style: theme.bodyText)),
    ]
  );
}
