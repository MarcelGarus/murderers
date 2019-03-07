
enum FunctionStatus {
  success,
  no_internet,
  no_server,
  timeout,
  server_corrupt,
  access_denied,
  game_not_found,
}

// TODO: comment as beatiful as below
/*/// These are all possible setup statuses that the [SetupResult] can contain.
/// Note that depending on how the game is set up, not necessarily all of them
/// can occur.
enum SetupStatus {
  /// The game was successfully set up.
  success,

  /// There's no connection to the internet.
  no_internet,

  /// The server couldn't be found. Maybe it's down or there's restricted
  /// network access.
  no_server,

  /// The connection timed out. Probably, the connection got interrupted or the
  /// network connection is just really bad.
  timeout,

  /// The server sent an unexpected response code or content.
  server_corrupt,

  /// The access got denied. Probably the device didn't send a valid Firebase
  /// ID token.
  access_denied,

  /// A game with the given code doesn't exist.
  game_not_found,
}
*/
