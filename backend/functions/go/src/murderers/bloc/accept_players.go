package bloc

import (
	"murderers/context"
	. "murderers/foundation"
)

// AcceptPlayers accepts the players with the given IDs.
func AcceptPlayers(
	c *context.C,
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

	// Make sure all those users are actually trying to join the game.
	for _, id := range playersToAccept {
		if _, found := game.Joining[id]; !found {
			return UserNotJoiningError(id)
		}
	}

	// Actually create players for all the joining users.
	for joiningID := range game.Joining {
		user, err := c.LoadUser(joiningID)
		if err != nil {
			return err
		}
		player := Player{
			Code:           game.Code,
			User:           user,
			State:          PlayerAlive,
			Murderer:       PlayerReference{},
			Victim:         PlayerReference{},
			WantsNewVictim: true,
			Death:          Death{},
			Kills:          0,
		}
		c.SavePlayer(player)
	}

	return nil
}
