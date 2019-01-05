import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'death.dart';

part 'player.g.dart';

enum PlayerState {
  idle,
  waiting,
  alive,
  dying,
  dead
}

PlayerState intToPlayerState(int i) {
  switch (i) {
    case 0: return PlayerState.idle;
    case 1: return PlayerState.waiting;
    case 2: return PlayerState.alive;
    case 3: return PlayerState.dying;
    case 4: return PlayerState.dead;
    default:
      print("Error: Unknown player state $i.");
      throw ArgumentError();
  }
}

/// A player.
///
/// The term player refers to all users participating in a game. Players only
/// exist in the context and scope of games - if a user plays in two games, he
/// is represented by two distinct players.
@JsonSerializable()
class Player {
  String id;
  String name;
  PlayerState state;
  List<Death> deaths;
  int kills;

  bool get isAlive => state == PlayerState.alive || state == PlayerState.dying;

  Player({
    @required this.id,
    @required this.name,
    this.state = PlayerState.waiting,
    this.deaths,
    this.kills = 0
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
