package main

import (
	"errors"
	"time"
)

func generateUniqueGameCode(s Storage) (GameCode, error) {
	var code GameCode
	tries := 0

	loop: for {
		code = GameCode(generateRandomString(GameCodeCharacters, GameCodeLength))
		tries++

		if _, err := s.LoadGame(code); err != nil {
			if serr, ok := err.(*GameNotFoundError); ok {
				// The game couldn't be found, so the code is free to take.
				break loop
			} else {
				return "", serr
			}
		}
		
		if tries >= GameCodeMaxTries {
			return "", errors.New("create_user: Exceeded maximum number of tries while generating a user id.")
		}
	}

  return code, nil
}

func CreateGame(s Storage, name string, end time.Time, creator UserId, authToken string) (Game, error) {
	var game Game
	var user User
	var code GameCode
	
	// Load and validate the user.
	if user, err := s.LoadUser(creator); err != nil {
		return game, err
	} else if ok = validateUser(user, authToken); !ok {
		return game, errors.New("create_game: authentication failed")
	}

	// Generate a unique game code.
	if code, err := generateUniqueGameCode(s); err != nil {
		return game, err
	}

	game = Game{
		Code: "TODO",
		Name: name,
		State: GameNotStartedYet,
		Creator: creator,
		Created: time.Now(),
		End: end,
	}
}
