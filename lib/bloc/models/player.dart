import 'death.dart';

/// A player.
///
/// The term player refers to all users participating in a game. Players only
/// exist in the context and scope of games - if a user plays in two games, he
/// is represented by two distinct players.
class Player {
  String id;
  String name;
  Death death;
  bool get isAlive => death != null;
}
