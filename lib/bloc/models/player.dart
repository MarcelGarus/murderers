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
@immutable
class Player {
  final String id; // A unique id.
  final String name; // A given name.
  final PlayerState state;
  final List<Death> deaths; // All the player's deaths.
  final int kills; // How many other players this player killed.

  bool get isAlive => state == PlayerState.alive || state == PlayerState.dying;

  Player({
    @required this.id,
    @required this.name,
    this.state = PlayerState.waiting,
    this.deaths = const [],
    this.kills = 0
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
