package bloc

import (
	"errors"
	"time"
)

func generateUniqueGameCode(s Storage) (GameCode, ErrorWithStatus) {
	var code GameCode
	tries := 0

	loop: for {
		code = GameCode(generateRandomString(GameCodeCharacters, GameCodeLength))
		tries++

		if _, err := s.LoadGame(code); err != nil {
			// No game with that code exists, so the code is free to take.	
			break loop
		}

		if tries >= GameCodeMaxTries {
			return nil, InternalServerError("Exceeded maximum number of tries while generating a game code.")
		}
	}

	return code, nil
}

func CreateGame(s Storage, me UserId, authToken string, name string, end time.Time) (Game, error) {
	var user User
	var code GameCode
	var game Game

	// Load and validate the user.
	if user, err := s.LoadUser(me); err != nil {
		return game, err
	} else if ok = validateUser(user, authToken); !ok {
		return game, AuthenticationFailedError()
	}

	// Generate a unique game code.
	if code, err := generateUniqueGameCode(s); err != nil {
		return game, err
	}

	game = Game{
		Code: "TODO",
		Name: name,
		State: GameNotStartedYet,
		Creator: me,
		Created: time.Now(),
		End: end,
	}

	s.SaveGame(game)
}
