import 'package:flutter/material.dart';

class SetupAppBar extends StatelessWidget {
  SetupAppBar({
    @required this.title,
    this.subtitle
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Text(title,
        style: TextStyle(
          fontFamily: 'Signature',
          fontSize: 28.0,
          color: Colors.white
        )
      )
    ];

    if (subtitle != null) {
      items.addAll([
        SizedBox(height: 8.0),
        Text(subtitle, style: TextStyle(color: Colors.white)),
      ]);
    }

    return Material(
      color: Theme.of(context).primaryColor,
      elevation: 2.0,
      child: Container(
        height: 150.0,
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: items
          )
        )
      )
    );
  }
}


class SetupBottomBar extends StatelessWidget {
  SetupBottomBar({
    this.primary,
    this.secondary,
    this.onPrimary,
    this.onSecondary,
  });

  final String primary;
  final String secondary;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (secondary != null) {
      items.add(_buildButton(text: secondary, onPressed: onSecondary));
    }

    items.add(Spacer());

    if (primary != null) {
      final color = Theme.of(context).primaryColor;
      items.add(_buildButton(
        text: primary,
        icon: Icon(Icons.keyboard_arrow_right, color: color),
        onPressed: onPrimary,
        color: color
      ));
    }

    return Material(elevation: 2.0, child: Row(children: items));
  }

  Widget _buildButton({
    @required String text,
    Widget icon,
    @required VoidCallback onPressed,
    Color color
  }) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      containedInkWell: true,
      //radius: 100.0,
      onTap: onPressed,
      child: Container(
        height: 48.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(text.toUpperCase(),
              style: color == null ? null : TextStyle(
                fontWeight: FontWeight.bold,
                color: color
              )
            ),
            icon ?? Container(height: 0.0)
          ],
        )
      ),
    );
  }
}


class SetupRoute extends PageRouteBuilder {
  SetupRoute(
    Widget child
  ) : super(
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext context, _, __) => child,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> primaryAnimation,
      Animation<double> secondaryAnimation,
      Widget child
    ) {
      final primary = CurvedAnimation(curve: Curves.easeInOut, parent: primaryAnimation);
      final secondary = CurvedAnimation(curve: Curves.easeInOut, parent: secondaryAnimation);

      return SlideTransition(
        position: Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(primary),
        child: SlideTransition(
          position: Tween(
            begin: Offset.zero,
            end: const Offset(-1.0, 0.0),
          ).animate(secondary),
          child: child,
        ),
      );
    }
  );
}


class ModeIcon extends StatefulWidget {
  ModeIcon({
    @required this.selected,
    @required this.iconData,
  });

  final bool selected;
  final IconData iconData;

  @override
  _ModeIconState createState() => _ModeIconState();
}

class _ModeIconState extends State<ModeIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      width: 48.0,
      decoration: BoxDecoration(
        color: widget.selected ? Colors.red : Colors.black26,
        shape: BoxShape.circle
      ), 
      child: Icon(widget.iconData, color: Colors.white)
    );
  }
}

