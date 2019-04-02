package bloc

import (
	. "murderers/context"
	. "murderers/foundation"
	"time"
)

// CreateGame creates a new game.
func CreateGame(
	c MyContext,
	me UserID,
	authToken string,
	name string,
	end time.Time,
) (Game, RichError) {
	// Load and validate the user.
	user, err := c.Storage.LoadUser(me)
	if err != nil {
		return nil, err
	} else if ok, err = c.AuthenticateUser(user, authToken); err != nil {
		return nil, err
	} else if !ok {
		return nil, AuthenticationFailedError()
	}

	// Generate a unique game code.
	var code GameCode
	tries := 0
	for {
		code = GameCode(generateRandomString(GameCodeCharacters, GameCodeLength))
		tries++
		if _, err := s.LoadGame(code); err != nil {
			break // No game with that code exists, so the code is free to take.
		}
		if tries >= GameCodeMaxTries {
			return nil, InternalServerError("Exceeded maximum number of tries while generating a game code.")
		}
	}

	// Create a new game.
	game := Game{
		Code:    "TODO",
		Name:    name,
		State:   GameNotStartedYet,
		Creator: me,
		Created: time.Now(),
		End:     end,
	}

	// Save the game.
	if err := c.p.SaveGame(game); err != nil {
		return nil, err
	}

	return game, nil
}
