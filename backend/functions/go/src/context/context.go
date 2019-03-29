package context

import (
	"storage"
)

// Context that provides all the basic functionality.
type Context struct {
	s Storage
}

func (c *Context) LoadAndAuthenticatePlayer(
	code GameCode,
	id UserID,
	authToken string
) (Player, ErrorWithStatus) {
	var player Player
	
	if player, err = c.s.LoadPlayer(code, id); err != nil {
		return nil, err
	}
	if player.User.AuthToken != authToken {
		return nil, Authen
	}
}

// GetPlayer extends the User to return the corresponding player for a game.
func (user *User) GetPlayer(c Context, code GameCode) (Player, ErrorWithStatus) {
	return c.s.LoadPlayer(code, user.ID)
}

// Get extends the PlayerReference to return the actual player.
func (r *PlayerReference) Get(c Context) (Player, ErrorWithStatus) {
	return c.s.LoadPlayer(r.Code, r.ID)
}
