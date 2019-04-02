package bloc

import (
	. "murderers/context"
	. "murderers/foundation"
)

// Die kills finishes a player off and provides a new victim to the murderer.
func Die(
	c Context,
	me UserID,
	authToken string,
	code GameCode,
	weapon string,
	lastWords string,
) RichError {
	// Load and authenticate the murderer.
	var murderer Player
	if m, err = c.s.LoadAuthenticatedPlayer(code, me, authToken); err != nil {
		return nil, err
	} else {
		murderer = m
	}

	// Verify that the victim is dying.
	var victim Player
	if v, err := player.Victim.Get(); err != nil {
		return nil, err
	} else if v.State != PlayerDying {
		return nil, VictimNotDyingError()
	} else {
		victim = v
	}

	// Load players who got accepted and have no victim yet.
	var newPlayers []Player
	if p, err := c.s.LoadNewPlayers(); err != nil {
		return nil, err
	}
	newPlayers = p

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

	return "You died.", nil
}

type Subgraph struct {
	start Player
	end   Player
}
