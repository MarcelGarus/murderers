package bloc

import (
	"fmt"
	. "murderers/foundation"
)

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

// AlreadyJoinedError indicates that the user already joined the game.
func AlreadyJoinedError() RichError {
	return BadRequestError(20, "You already joined the game.")
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

// GameAlreadyStartedError indicates that the creator attempted to start a game
// which was already running.
func GameAlreadyStartedError() RichError {
	return BadRequestError(20, fmt.Sprintf(
		"The game is already running."))
}

// NotEnoughPlayersError indiciates that the creator attempted to start the game
// but there are not enough  players to do so.
func NotEnoughPlayersError(numPlayers int) RichError {
	return BadRequestError(20, fmt.Sprintf(
		"There are only %d player, but %d are required to start the game.",
		numPlayers, MinimumPlayersToStart))
}

// VictimNotMatchingError indicates that the victim id provided to the function
// doesn't match the actual one. This may occur if the function is called
// multiple times. See [kill_player.go] for more information.
func VictimNotMatchingError() RichError {
	return BadRequestError(20,
		"The provided victim's id doesn't match with the actual one.")
}

// VictimNotDyingError indicates TODO:
func VictimNotDyingError() RichError {
	return BadRequestError(27, "The victim isn't dying.")
}
