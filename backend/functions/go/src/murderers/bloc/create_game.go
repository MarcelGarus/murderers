package bloc

import (
	"murderers/context"
	. "murderers/foundation"
	"time"
)

// CreateGame creates a new game.
func CreateGame(
	c *context.C,
	me UserID,
	authToken string,
	name string,
	end time.Time,
) (Game, RichError) {
	// Load and validate the user.
	user, err := c.LoadUserAndAuthenticate(me, authToken)
	if err != nil {
		return Game{}, err
	}

	// Generate a unique game code.
	var code GameCode
	tries := 0
	for {
		code = GameCode(generateRandomString(GameCodeCharacters, GameCodeLength))
		tries++
		if _, err := c.LoadGame(code); err != nil {
			break // No game with that code exists, so the code is free to take.
		}
		if tries >= GameCodeMaxTries {
			return Game{}, ExceededNumberOfTriesWhileGeneratingCodeError()
		}
	}

	// Create a new game.
	game := Game{
		Code:    code,
		Name:    name,
		State:   GameNotStartedYet,
		Creator: user,
		Created: time.Now(),
		End:     end,
	}

	// Save the game.
	if err := c.SaveGame(game); err != nil {
		return Game{}, err
	}

	return game, nil
}
