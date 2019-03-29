package storage

import (
	"fmt"
	. "foundation"
)

// UserNotFoundError indicates that a user with the given id doesn't exist.
func UserNotFoundError(id UserID) RichError {
	return ResourceNotFoundError(10, fmt.Sprintf(
		"User %s not found.", string(id)))
}

// UserCorruptError indicates that the requested user's data is corrupt.
func UserCorruptError(id UserID) RichError {
	return InternalServerError(11, fmt.Sprintf(
		"User %s is corrupt.", string(id)))
}

// GameNotFoundError indicates that a game with the given code doesn't exist.
func GameNotFoundError(code GameCode) RichError {
	return ResourceNotFoundError(12, fmt.Sprintf(
		"Game %s not found.", string(code)))
}

// GameCorruptError indicates that the requested game's data is corrupt.
func GameCorruptError(code GameCode) RichError {
	return InternalServerError(13, fmt.Sprintf(
		"User %s is corrupt.", string(code)))
}

// PlayerNotFoundError indicates that a player with the given id in the game
// with the given code doesn't exist.
func PlayerNotFoundError(code GameCode, id UserID) RichError {
	return ResourceNotFoundError(14, fmt.Sprintf(
		"Player %s not found in game %s.", string(id), string(code)))
}

// PlayerCorruptError indicates that the requested player's data is corrupt.
func PlayerCorruptError(code GameCode, id UserID) RichError {
	return InternalServerError(15, fmt.Sprintf(
		"Player %s of game %s is corrupt.", string(id), string(code)))
}
