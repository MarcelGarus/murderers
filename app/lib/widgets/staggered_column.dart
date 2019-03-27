import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';

class StaggeredColumn extends StatelessWidget {
  const StaggeredColumn({
    @required this.children,
    this.totalDuration = const Duration(milliseconds: 600),
    this.singleDuration = const Duration(milliseconds: 400),
  })  : assert(children != null),
        assert(totalDuration != null),
        assert(singleDuration != null);

  final List<Widget> children;
  final Duration totalDuration;
  final Duration singleDuration;

  @override
  Widget build(BuildContext context) {
    var numChildren = this.children.length;
    var delay = Duration(
        microseconds:
            ((totalDuration - singleDuration).inMicroseconds / numChildren)
                .round());
    var children = <Widget>[];

    // Wrap all the children in Villains that animate them with the correct
    // layout.
    for (int i = 0; i < numChildren; i++) {
      var from = Duration(microseconds: (delay.inMicroseconds * i));
      var to = from + singleDuration;
      var child = this.children[i];

      // To retain the effect of Expanded widgets, don't wrap themselves but
      // rather their children.
      if (child is Expanded) {
        children.add(Expanded(
          key: child.key,
          flex: child.flex,
          child: _buildVillain(from, to, child.child),
        ));
        continue;
      }

      // The same is true for Spacer widgets.
      if (child is Spacer) {
        children.add(Spacer());
        continue;
      }

      // Otherwise, just wrap the widget in a villain.
      children.add(_buildVillain(from, to, child));
    }

    return Column(children: children);
  }

  Widget _buildVillain(Duration from, Duration to, Widget child) {
    return Villain(
      villainAnimation: VillainAnimation.transformTranslate(
        fromOffset: Offset(0, 100),
        toOffset: Offset.zero,
        from: from,
        to: to,
        curve: Curves.easeOutCubic,
      ),
      secondaryVillainAnimation: VillainAnimation.fade(),
      child: child,
    );
  }
}
