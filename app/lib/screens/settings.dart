import 'package:flare_flutter/flare_actor.dart';
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

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Settings',
      children: <Widget>[
        _SettingsItem(
          title: 'Account',
          summary: 'signed in as Marcel Garus via Google',
          leading: CircleAvatar(
            backgroundColor: Colors.black12,
            backgroundImage: NetworkImage(Bloc.of(context).accountPhotoUrl),
          ),
          pageBuilder: () => _AccountSettings(),
        ),
        _SettingsItem(
          title: 'Games',
          summary: 'participating in 1 game',
          leading: Icon(Icons.filter_none, color: Colors.black),
          pageBuilder: () => _GameSettings(),
        ),
        _SettingsItem(
          title: 'Notifications',
          summary: 'all enabled',
          leading: Icon(Icons.notifications_none, color: Colors.black),
          pageBuilder: () => _NotificationSettings(),
        ),
        _SettingsItem(
          title: 'Privacy',
          summary: 'analytics enabled',
          leading: Icon(Icons.lock_outline, color: Colors.black),
          pageBuilder: () => _PrivacySettings(),
        ),
        _SettingsItem(
          title: 'About & license',
          summary: 'running 1.0.2-beta+4',
          leading: Icon(Icons.info_outline, color: Colors.black),
          pageBuilder: () => _About(),
        ),
      ],
    );
  }
}

class _SettingsScaffold extends StatelessWidget {
  const _SettingsScaffold({
    @required this.title,
    @required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    var theme = kThemeLight;

    return MyTheme(
      data: theme,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 200,
              iconTheme: IconThemeData(color: Colors.black),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(color: Colors.black.withOpacity(0.04)),
                title: Text(title, style: TextStyle(color: Colors.black)),
              ),
            ),
            SliverList(delegate: SliverChildListDelegate(children)),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    @required this.title,
    @required this.summary,
    @required this.leading,
    @required this.pageBuilder,
  });

  final String title;
  final String summary;
  final Widget leading;
  final Widget Function() pageBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(title),
          subtitle: Text(summary),
          leading: Container(
            width: 42,
            alignment: Alignment.center,
            child: leading,
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => pageBuilder(),
            ));
          },
        ),
        Divider(height: 0),
      ],
    );
  }
}

class _AccountSettings extends StatelessWidget {
  Widget build(BuildContext context) {
    var bloc = Bloc.of(context);
    var theme = MyTheme.of(context);

    return _SettingsScaffold(
      title: 'Account',
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.black12,
                backgroundImage: NetworkImage(bloc.accountPhotoUrl),
                radius: 20,
              ),
              SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    bloc.name,
                    style: theme.bodyText.copyWith(fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  Text('signed in with Google', style: theme.bodyText),
                  SizedBox(height: 16),
                  Button.text(
                    'Change name',
                    isRaised: false,
                    onPressed: () => _displayNotImplementedSnackbar(context),
                  ),
                  Button.text(
                    'Sign out',
                    isRaised: false,
                    onPressed: bloc.signOut,
                  ),
                  Button.text(
                    'Delete account',
                    isRaised: false,
                    onPressed: () => _displayNotImplementedSnackbar(context),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _GameSettings extends StatelessWidget {
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Games',
      children: Bloc.of(context).allGames.map<Widget>((game) {
        return ListTile(
          leading: CircleAvatar(child: Text(game.code)),
          title: Text(game.name),
          subtitle: Text('Tap to continue with this game'),
        );
      }).toList(),
    );
  }
}

class _NotificationSettings extends StatelessWidget {
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Notifications',
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
        SizedBox(height: 16),
        Button.text(
          'Request notification permissions (only needed on iOS)',
          isRaised: false,
          onPressed: () => _displayNotImplementedSnackbar(context),
        ),
      ],
    );
  }
}

class _PrivacySettings extends StatelessWidget {
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Privacy',
      children: <Widget>[
        SizedBox(height: 16),
        Text(
            "The backend of this app runs on Google's servers. That means, some "
            "information about your device as well as the actions you take "
            "inside the app are sent to Google."),
        _buildCheckbox(
          context: context,
          value: true,
          onChanged: (_) => _displayNotImplementedSnackbar(context),
          label: 'Provide analytics data, like device information and how you '
              'interact with the app to make the app better.',
        ),
        Button.text(
          'Read the privacy policy',
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
    return _SettingsScaffold(
      title: 'About',
      children: <Widget>[
        SizedBox.fromSize(
          size: Size.square(128),
          child: FlareActor('images/logo.flr', animation: 'intro'),
        ),
        Text('Murderers\n1.0.2-beta+4', textAlign: TextAlign.center),
        SizedBox(height: 16),
        _buildNames(context, 'Developer', [
          'Marcel Garus',
        ]),
        _buildNames(context, 'Testers', [
          'TODO: make sure they are okay with being listed here',
          'Marcel Garus',
        ]),
        SizedBox(height: 16),
        FlutterLogo(size: 46),
        SizedBox(height: 16),
        Text(
          'This app was built with Flutter.\n'
              'It is open source. Feel free to contribute on Github.\n'
              'Issues and feature requests are welcome.',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Center(
          child: Button.text(
            'Open Github repository',
            onPressed: () {
              const url = 'https://www.github.com/marcelgarus/murderers';
              () async {
                if (await canLaunch(url)) {
                  await launch(url);
                }
              }();
            },
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Button.text(
            'View licenses',
            isRaised: false,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => LicensePage(
                      applicationName: 'Murderers',
                      applicationVersion: '1.0.2-beta+4',
                    ),
              ));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNames(BuildContext context, String title, List<String> names) {
    var theme = MyTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          style: theme.bodyText.copyWith(fontFamily: 'Signature'),
        ),
        SizedBox(height: 8),
        Text(
          names.join('\n'),
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

  return Row(children: <Widget>[
    Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: theme.flatButtonColor,
    ),
    Expanded(child: Text(label, style: theme.bodyText)),
  ]);
}
