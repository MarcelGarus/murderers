import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'death.dart';

part 'player.g.dart';

/// A player.
///
/// The term player refers to all users participating in a game. Players only
/// exist in the context and scope of games - if a user plays in two games, he
/// is represented by two distinct players.
@JsonSerializable()
class Player {
  String id;
  String name;
  Death death;
  bool get isAlive => death != null;

  Player({
    @required this.id,
    @required this.name,
    this.death
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
