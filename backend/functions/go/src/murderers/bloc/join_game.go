package bloc

import (
	"murderers/context"
	. "murderers/foundation"
)

// JoinGame joins a user in a game. The game creator still needs to approve the
// user before he actually joins the game. That happens in [accept_players.go].
func JoinGame(
	c *context.C,
	me UserID,
	authToken string,
	code GameCode,
) RichError {
	// Load and authenticate the user.
	user, err := c.LoadUserAndAuthenticate(me, authToken)
	if err != nil {
		return err
	}

	// Load the game.
	game, err := c.LoadGame(code)
	if err != nil {
		return err
	}

	// Make sure the user didn't already join the game.
	if isJoining, ok := game.Joining[me]; ok && isJoining {
		return AlreadyJoinedError()
	} else if _, err := c.LoadPlayer(code, me); err == nil {
		return AlreadyJoinedError()
	}

	// Make the user join the game.
	game.Joining[me] = true
	c.SaveGame(game)

	// If the user is the creator, instantly join without waiting for approval.
	if user.ID == game.Creator.ID {
		err = AcceptPlayers(c, me, authToken, code, []UserID{me})
		if err != nil {
			return err
		}
	}

	return nil
}
