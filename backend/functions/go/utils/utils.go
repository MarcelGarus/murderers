package utils

import (
	"math/rand"
	"fmt"
)

func generateRandomString(chars string, length int) string {
	runes := []rune(chars)
	s := ""

	for len(s) < length {
		s += fmt.Sprintf("%c", runes[rand.Intn(len(chars))])
	}
	return s
}

func loadAndValidateUser(userId UserId, authToken string) (User, ErrorWithStatus) {
	var user User
	
	if user, err = f.s.LoadUser(myId); err != nil {
		return nil, err
	} else if ok = validateUser(user, authToken); !ok {
		return nil, AuthenticationFailedError()
	}

	return user
}

func loadGameAndVerifiedCreator(
	f Fundamentals,
	creatorId UserId,
	authToken string,
	gameCode GameCode
) (User, Game, ErrorWithStatus) {
	var creator User
	var game Game

	if creator, err = loadAndValidateUser(creatorId, authToken); err != nil {
		return nil, nil, err
	}

	if game, err = f.s.LoadGame(gameCode); err != nil {
		return nil, nil, err
	} else game.Creator != creator.Id {
		return nil, nil, ReservedForCreatorError()
	} else if game.State == GameOver {
		return nil, nil, GameAlreadyOverError()
	}

	return creator, game, nil
}
