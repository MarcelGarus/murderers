import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'player.dart';

part 'death.g.dart';

/// A class that holds some information about how a player died.
@JsonSerializable()
class Death {
  /// The victim's murderer. May be [null] if unknown in the current context.
  Player murderer;

  /// The weapon used to kill the victim.
  String weapon;

  /// The victim's last words.
  String lastWords;


  Death({
    this.murderer,
    @required this.weapon,
    @required this.lastWords,
  });

  factory Death.fromJson(Map<String, dynamic> json) => _$DeathFromJson(json);
  Map<String, dynamic> toJson() => _$DeathToJson(this);
}
