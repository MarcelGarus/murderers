import 'package:flutter/material.dart';

import '../../bloc/bloc.dart';
import '../../widgets/button.dart';
import '../../widgets/theme.dart';

class DyingDashboard extends StatelessWidget {
  DyingDashboard(this.game);
  final Game game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: <Widget>[
          Spacer(),
          Text("Did you get killed?",
            style: MyTheme.of(context).headerText,
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Weapon',
            ),
            style: TextStyle(
              fontFamily: 'Signature',
              color: Colors.white,
              fontSize: 32
            ),
            //onChanged: (name) => setState(() => config.gameName = name),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Last words',
            ),
            style: TextStyle(
              fontFamily: 'Signature',
              color: Colors.white,
              fontSize: 32
            ),
            //onChanged: (name) => setState(() => config.gameName = name),
          ),
          SizedBox(height: 16),
          Row(
            children: <Widget>[
              Spacer(),
              Button(
                text: "I didn't get killed",
                isRaised: false,
                onPressed: () {},
              ),
              SizedBox(width: 8),
              Button(
                text: 'Confirm murder',
                onPressed: () {
                  return Bloc.of(context).confirmDeath(
                    weapon: 'Some weapon',
                    lastWords: 'Last words',
                  );
                },
              ),
            ],
          ),
          Spacer(),
        ]
      )
    );
  }
}
