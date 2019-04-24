package bloc

import (
	"math/rand"
	"murderers/context"
	. "murderers/foundation"
	"time"
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
	rand.Seed(time.Now().UnixNano())
	rand.Shuffle(len(players), func(i, j int) {
		players[i], players[j] = players[j], players[i]
	})
	for i, player := range players {
		if i > 0 {
			player.Victim = players[i-1].ToReference()
		} else {
			player.Victim = players[len(players)-1].ToReference()
		}
		c.SavePlayer(player)
	}

	// Update the game.
	game.State = GameRunning
	c.SaveGame(game)

	// TODO: Notify everyone that the game started.

	return nil
}
