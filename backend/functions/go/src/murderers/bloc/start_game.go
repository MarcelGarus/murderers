package bloc

import (
	"murderers/context"
	. "murderers/foundation"
)

// StartGame starts a game.
func StartGame(
	c *context.C,
	code GameCode,
	me UserID,
	authToken string,
) RichError {
	// Load the game. Only the creator can perform this action.
	// Also, make sure the game didn't start yet.
	game, err := c.LoadGameForCreatorAction(code, me, authToken)
	if err != nil {
		return err
	} else if game.State != GameNotStartedYet {
		return GameAlreadyStartedError()
	}

	// Get all the players and make sure there are enough.
	players, err := c.LoadAllPlayers(code)
	if err != nil {
		return err
	} else if len(players) < MinimumPlayersToStart {
		return NotEnoughPlayersError(len(players))
	}

	// Shuffle all the players and update their victims.
	satisfyPlayers(c, code)

	// Update the game.
	game.State = GameRunning
	c.SaveGame(game)

	// TODO: Notify everyone that the game started.

	return nil
}
