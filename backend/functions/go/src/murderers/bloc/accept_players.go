package bloc

import (
	"murderers/context"
	. "murderers/foundation"
)

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
	game.Joining

	// Make sure all those users are actually trying to join the game.
	for id := range playersToAccept {
		if _, found = game.Joining[id]; !found {
			return nil, UserNotJoiningError(id)
		}
	}

	// Accept all the players by changing their state.
	for id := range playersToAccept {
		player, err := c.s.LoadPlayer(code, id)
		if err != nil {
			return nil, err
		}
		player.State = PlayerAlive
		player.WantsNewVictim = true
	}

	return nil
}
