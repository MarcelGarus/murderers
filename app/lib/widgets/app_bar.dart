import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../screens/settings.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  Size get preferredSize => Size.fromHeight(56);

  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actionsIconTheme: IconThemeData(color: Colors.black),
      actions: <Widget>[
        Align(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => SettingsScreen()
              ));
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(Bloc.of(context).accountPhotoUrl),
              radius: 20,
            ),
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }
}
