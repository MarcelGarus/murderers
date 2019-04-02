package context

import . "murderers/foundation"

// ReservedForCreatorError indicates that a non-creator attempted to execute an
// action that only the creator is able to execute.
func ReservedForCreatorError() RichError {
	return NoPrivilegesError(21, "Only the creator can execute this action.")
}

// GameAlreadyOverError indicates that an action was tried to perform that can't
// be executed when the game is already over.
func GameAlreadyOverError() RichError {
	return BadRequestError(26, "The game is already over.")
}
