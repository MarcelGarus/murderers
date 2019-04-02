package bloc

import (
	"murderers/context"
	. "murderers/foundation"
)

// Die kills finishes a player off and provides a new victim to the murderer.
func Die(
	c context.C,
	me UserID,
	authToken string,
	code GameCode,
	weapon string,
	lastWords string,
) RichError {
	// Load and authenticate the murderer.
	murderer, err := c.LoadAndAuthenticatePlayer(code, me, authToken)
	if err != nil {
		return err
	}

	// Verify that the victim is dying.
	victim, err := c.GetPlayer(*murderer.Victim)
	if err != nil {
		return err
	} else if victim.State != PlayerDying {
		return VictimNotDyingError()
	}

	// Load players who got accepted and have no victim yet.
	var newPlayers, err := c.Storage.LoadNewPlayers()
	if err != nil {
		return err
	}

	// Load all the players who want a new victim.
	var playersWhoWantNewVictims []Player
	if p, err := c.s.LoadPlayersWhoWantNewVictim(); err != nil {
		return nil, err
	}
	playersWhoWantNewVictims = p

	// Shuffle new players.
	shuffleVictims(newPlayers)

	if newPlayers.length > 0 {
		murderer.victim = newPlayers[0].id
		newPlayers[0].data.victim = victim.victim
	} else {
		murderer.victim = victim.victim
	}

	// Shuffle players who want a new victim.
	// We do that
	if len(playersWhoWantNewVictim) >= 3 {
		var splitted []Subgraph
		var current = murderer
		var start Player

		// Split the graph of players into subgraphs, each represented by a
		// start player and and end player (the one who wants a new victim)
		for {
			if start == nil {
				start = current
			}
			if current.wantsNewVictim {
				splitted.append(Subgraph{
					start: start,
					end:   current,
				})
				start = nil
			}
			if current == murderer {
				break
			}
			current = current.victim.Get()
		}
		if !current.wantsNewVictim {
			splitted[0] = Subgraph{
				start: current,
				end:   splitted[0].end,
			}
		}

		// Then, reverse the direction in which the subgraphs are connected.
		for i = 0; i < len(splitted); i++ {
			if i > 0 {
				splitted[i].end.Victim = splitted[i-1].start.ToReference()
			} else {
				splitted[i].end.Victim = splitted[len(splitted)-1].start.ToReference()
			}
		}
	}

	// TODO: Notify players that their victims changed.

	return "You died.", nil
}

type Subgraph struct {
	start Player
	end   Player
}
