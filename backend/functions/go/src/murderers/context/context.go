package context

import (
	"murderers/auth"
	. "murderers/foundation"
	"murderers/storage"
)

// C that provides all the basic functionality.
type C struct {
	storage storage.Storage
}

// NewContext creates a new context.
func NewContext(storage storage.Storage) C {
	return C{
		storage: storage,
	}
}

// AuthenticateUser authenticates a user.
// TODO: for now, this just compares the authToken. Realistically, we should
// store the uid token and use Firebase to convert the given auth token
// (formally known as a Firebase id token) to the uid and compare that to the
// stored one.
func (c *C) AuthenticateUser(
	user User,
	authToken string,
) RichError {
	return auth.AuthenticateClient(user.FirebaseID, authToken)
}

// LoadUser loads a user.
func (c *C) LoadUser(id UserID) (*User, RichError) {
	return c.storage.LoadUser(id)
}

// LoadUserAndAuthenticate loads a user and authenticates it.
func (c *C) LoadUserAndAuthenticate(
	id UserID,
	authToken string,
) (*User, RichError) {
	user, err := c.storage.LoadUser(id)

	if err != nil {
		return nil, err
	} else if err := c.AuthenticateUser(*user, authToken); err != nil {
		return nil, err
	}

	return user, nil
}

// SaveUser saves a user.
func (c *C) SaveUser(user User) RichError {
	return c.storage.SaveUser(user)
}

// DeleteUser deletes a user.
func (c *C) DeleteUser(user User) RichError {
	return c.storage.DeleteUser(user)
}

// LoadGame loads a game.
func (c *C) LoadGame(code GameCode) (*Game, RichError) {
	return c.storage.LoadGame(code)
}

// LoadGameForCreatorAction loads a game and verifies that the provided id is
// the creator's one and the authToken is correct and the game is not already
// over.
func (c *C) LoadGameForCreatorAction(
	gameCode GameCode,
	creatorID UserID,
	authToken string,
) (*Game, RichError) {
	game, err := c.storage.LoadGame(gameCode)

	if err != nil {
		return nil, err
	} else if game.Creator.ID != creatorID {
		return nil, ReservedForCreatorError()
	} else if err := c.AuthenticateUser(game.Creator, authToken); err != nil {
		return nil, err
	} else if game.State == GameOver {
		return nil, GameAlreadyOverError()
	}

	return game, nil
}

// SaveGame saves a game.
func (c *C) SaveGame(game Game) RichError {
	return c.storage.SaveGame(game)
}

// DeleteGame deletes a game.
func (c *C) DeleteGame(game Game) RichError {
	return c.storage.DeleteGame(game)
}

// LoadPlayer loads a player.
func (c *C) LoadPlayer(code GameCode, id UserID) (*Player, RichError) {
	return c.storage.LoadPlayer(code, id)
}

// LoadPlayerFromReference loads the player referenced by the given reference.
func (c *C) LoadPlayerFromReference(ref PlayerReference) (*Player, RichError) {
	return c.storage.LoadPlayer(ref.Code, ref.ID)
}

// LoadPlayerAndAuthenticate loads a player from a game and authenticates it.
func (c *C) LoadPlayerAndAuthenticate(
	code GameCode,
	id UserID,
	authToken string,
) (*Player, RichError) {
	player, err := c.storage.LoadPlayer(code, id)

	if err != nil {
		return nil, err
	} else if err := c.AuthenticateUser(player.User, authToken); err != nil {
		return nil, err
	}

	return player, nil
}

// SavePlayer saves a player.
func (c *C) SavePlayer(player Player) RichError {
	return c.storage.SavePlayer(player)
}

// DeletePlayer delete players.
func (c *C) DeletePlayer(player Player) RichError {
	return c.storage.DeletePlayer(player)
}
