package context

import (
	"murderers/auth"
	. "murderers/foundation"
	"murderers/storage"
)

// C that provides all the basic functionality.
type C struct {
	Storage storage.Storage
}

// GetPlayer return the actual player that a player reference points to.
func (c *C) GetPlayer(ref PlayerReference) (Player, RichError) {
	return c.Storage.LoadPlayer(ref.Code, ref.ID)
}

// AuthenticateUser authenticates a user.
// TODO: for now, this just compares the authToken. Realistically, we should
// store the uid token and use Firebase to convert the given auth token
// (formally known as an Firebase id token) to the uid and compare that to the
// stored one.
func (c *C) AuthenticateUser(
	user User,
	authToken string,
) RichError {
	auth.AuthenticateClient(user.FirebaseID, authToken)
}

// LoadAndAuthenticateUser loads a user and authenticates it.
func (c *C) LoadAndAuthenticateUser(
	id UserID,
	authToken string,
) (*User, RichError) {
	user, err := c.Storage.LoadUser(id)

	if err != nil {
		return nil, err
	} else if err := c.AuthenticateUser(user, authToken); err != nil {
		return nil, err
	}

	return &user
}

// LoadAndAuthenticatePlayer loads a player from a game and authenticates it.
func (c *C) LoadAndAuthenticatePlayer(
	code GameCode,
	id UserID,
	authToken string,
) (*Player, RichError) {
	player, err := c.Storage.LoadPlayer(code, id)

	if err != nil {
		return nil, err
	} else if ok, err := c.AuthenticateUser(player.User, authToken); err != nil {
		return nil, err
	} else if !ok {
		return nil, AuthenticationFailedError()
	}

	return &player, nil
}

// LoadGameForCreatorAction loads a game and verifies that the provided id is
// the creator's one and the authToken is correct and the game is not already
// over.
func (c *C) LoadGameForCreatorAction(
	gameCode GameCode,
	creatorID UserID,
	authToken string,
) (*Game, RichError) {
	game, err := c.Storage.LoadGame(gameCode)

	if err != nil {
		return nil, err
	} else if game.Creator.Id != creatorID {
		return nil, ReservedForCreatorError()
	} else if ok, err := AuthenticateUser(game.Creator, authToken); err != nil {
		return nil, err
	} else if !ok {
		return nil, AuthenticationFailedError()
	} else if game.State == GameOver {
		return nil, GameAlreadyOverError()
	}

	return &game, nil
}
