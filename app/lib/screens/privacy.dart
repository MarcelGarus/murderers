import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';
import '../widgets/theme.dart';

class PrivacyScreen extends StatefulWidget {
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  Widget build(BuildContext context) {
    var theme = MyTheme.of(context);
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Spacer(flex: 2),
          Text("Almost there!",
            textAlign: TextAlign.center,
            style: theme.headerText,
          ),
          SizedBox(height: 16),
          Text(
            "The backend of this app runs on Google's servers. That means, "
            "some information about your device as well as the actions you "
            "take inside the app are sent to Google. By continuing, you agree "
            "to the full privacy policy of the app.",
            style: theme.bodyText,
          ),
          SizedBox(height: 16),
          Row(
            children: <Widget>[
              Checkbox(
                value: Bloc.of(context).analyticsEnabled,
                onChanged: (isEnabled) => setState(() {
                  Bloc.of(context).analyticsEnabled = isEnabled;
                }),
                activeColor: kAccentColor,
              ),
              Expanded(
                child: Text(
                  'Make Marcel happy by providing analytics data, like device '
                  'information and how you interact with the app.',
                  style: theme.bodyText,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Button.text('Read the full privacy policy',
            isRaised: false,
            onPressed: () {
              Bloc.of(context).openPrivacyPolicy();
            },
          ),
          Spacer(),
        ],
      ),
    );
  }
}
