import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'player.dart';

part 'death.g.dart';

/// A class that holds some information about how a player died.
@JsonSerializable()
@immutable
class Death {
  final DateTime time; // The moment of death.
  final Player murderer; // The victim's murderer. May be [null].
  final String weapon; // The weapon used to kill the victim.
  final String lastWords; // The victim's last words.

  const Death({
    @required this.time,
    @required this.murderer,
    @required this.weapon,
    @required this.lastWords,
  });

  factory Death.fromJson(Map<String, dynamic> json) => _$DeathFromJson(json);
  Map<String, dynamic> toJson() => _$DeathToJson(this);
}
