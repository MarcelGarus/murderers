import 'user_role.dart';

/// A game configuration. It's passed between all the setup screens to carry
/// setup information through the setup flow.
class SetupConfiguration {
  /// The user's role in the game.
  UserRole role = UserRole.player;

  /// This player's name.
  /// 
  /// May be null if the user is not a player.
  String playerName;

  /// The game's code.
  /// 
  /// May be null if a new game is about to be created.
  String code;

  /// The game's name.
  /// 
  /// May be null if the game isn't newly created.
  String gameName;
}
