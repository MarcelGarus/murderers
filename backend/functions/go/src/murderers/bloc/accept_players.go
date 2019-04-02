package bloc

import (
	"murderers/context"
	. "murderers/foundation"
)

// AcceptPlayers accepts the players with the given IDs.
func AcceptPlayers(
	c context.C,
	me UserID,
	authToken string,
	code GameCode,
	playersToAccept []UserID,
) RichError {
	// Make sure there are players to accept.
	if len(playersToAccept) == 0 {
		return NoPlayersToAcceptError()
	}

	// Load the game.
	game, err := c.LoadGameForCreatorAction(code, me, authToken)
	if err != nil {
		return err
	}

	for joiningID := range game.Joining {
		user, err := c.Storage.LoadUser(joiningID)
		if err != nil {
			return err
		}
		player := Player{
			Code: game.Code,
			User: user,
		}
		c.Storage.SavePlayer(player)
	}

	// Make sure all those users are actually trying to join the game.
	for _, id := range playersToAccept {
		if _, found := game.Joining[id]; !found {
			return UserNotJoiningError(id)
		}
	}

	// Accept all the players by changing their state.
	for _, id := range playersToAccept {
		player, err := c.Storage.LoadPlayer(code, id)
		if err != nil {
			return err
		}
		player.State = PlayerAlive
		player.WantsNewVictim = true
	}

	return nil
}
