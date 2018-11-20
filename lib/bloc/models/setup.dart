import 'user_role.dart';

/// A game configuration. It's passed between all the setup screens to carry
/// setup information through the setup flow.
class SetupConfiguration {
  UserRole role = UserRole.PLAYER;
  String name;
  String code;
}
