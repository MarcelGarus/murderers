import 'package:flutter/material.dart';

class SetupRoute extends PageRouteBuilder {
  SetupRoute(Widget child)
      : super(
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (BuildContext context, _, __) => child,
            transitionsBuilder: (BuildContext context,
                Animation<double> primaryAnimation,
                Animation<double> secondaryAnimation,
                Widget child) {
              var primary = CurvedAnimation(
                  curve: Curves.easeInOut, parent: primaryAnimation);
              var secondary = CurvedAnimation(
                  curve: Curves.easeInOut, parent: secondaryAnimation);

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
            });
}
