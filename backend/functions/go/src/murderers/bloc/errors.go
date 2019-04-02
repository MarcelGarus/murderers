package bloc

import . "murderers/foundation"

// Quick note about error codes:
// 2x: General error.
// 3x: Error while creating a user.
// 4x: Error while creating a game.
// 5x: Error while...

// ExceededNumberOfTriesWhileGeneratingIDError indicates that no id could be
// generated because the maximum number of tries was used up.
func ExceededNumberOfTriesWhileGeneratingIDError() RichError {
	return InternalServerError(30,
		"Exceeded maximum number of tries while generating a user id.")
}

// ExceededNumberOfTriesWhileGeneratingCodeError indicates that no game code
// could be generated because the maximum number of tries was used up.
func ExceededNumberOfTriesWhileGeneratingCodeError() RichError {
	return InternalServerError(40,
		"Exceeded maximum number of tries while generating a game code.")
}

// NoPlayersToAcceptError indicates that the creator tried to accept players but
// didn't provide any.
func NoPlayersToAcceptError() RichError {
	return BadRequestError(24, "You provided no players to accept.")
}

// UserNotJoiningError indicates that the creator attempted to accept a player
// that didn't try to join the game.
func UserNotJoiningError(id UserID) RichError {
	return NoPrivilegesError(25, fmt.Sprintf(
		"You can't accept user %s, because it's not joining.", id))
}

// GameAlreadyOverError indicates that an action was tried to perform that can't
// be executed when the game is already over.
func GameAlreadyOverError() RichError {
	return BadRequestError(26, "The game is already over.")
}

// VictimNotDyingError indicates TODO:
func VictimNotDyingError() RichError {
	return BadRequestError(27, "The victim isn't dying.")
}
