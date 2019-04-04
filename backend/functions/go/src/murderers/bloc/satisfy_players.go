package bloc

import (
	"math/rand"
	"murderers/context"
	. "murderers/foundation"
)

// VictimChanged holds information about how a victim changed.
type VictimChanged struct {
	player       Player
	victimBefore PlayerReference
	victimAfter  PlayerReference
}

// satisfyPlayers tries to satisfy as many players as possible, doing the
// following:
// - Rearranging the graph so players who want new victims get some new ones.
// - Adding new players to the game.
// Before reading through this function, I recommend to make yourself familiar
// with the "Murderous graph" strategy in the project-level docs folder.
func satisfyPlayers(c *context.C, code GameCode) ([]VictimChanged, RichError) {
	// Which players got their victims changed.
	changedLog := make([]VictimChanged, 0)

	// Load all the players who want new victims.
	playersWhoWantNewVictims, err := c.LoadPlayersWhoWantNewVictims(code)
	if err != nil {
		return nil, err
	}

	// Split those players into new ones and ones who are unhappy with the
	// victim they have. The resulting slices are disjunct and their union is
	// the original slice.
	newPlayers := make([]Player, 0)
	unhappyPlayers := make([]Player, 0)
	for _, player := range playersWhoWantNewVictims {
		if (player.Victim == PlayerReference{}) {
			newPlayers = append(newPlayers, player)
		} else {
			unhappyPlayers = append(unhappyPlayers, player)
		}
	}

	// We can't break up the existing cycle or connect new players to form a new
	// one if there are no unhappy ones.
	if len(unhappyPlayers) == 0 {
		return changedLog, nil
	}

	// If there are at least 3 players who want new victims, split the graph of
	// players into subgraphs and reverse the order in which they are connected,
	// satisfying everyone.
	if len(playersWhoWantNewVictims) >= 3 {
		splitted, err := splitCycleIntoSubgraphs(c, unhappyPlayers[0])
		if err != nil {
			return nil, err
		}

		// Insert new players at random positions in the graph:
		// - Choose a random index to insert the element at.
		// - Add an element to ensure the slice has enough space.
		// - Shift all elements on the right side of the index to the right.
		// - Assign the new player's subgraph to the index.
		for _, player := range newPlayers {
			insertionIndex := rand.Intn(len(splitted) + 1)
			splitted = append(splitted, Subgraph{})
			copy(splitted[insertionIndex+1:], splitted[insertionIndex:])
			splitted[insertionIndex] = Subgraph{start: player, end: player}
		}

		// Reverse the direction in which the subgraphs are connected.
		for index, subgraph := range splitted {
			var victimSubgraph Subgraph
			if index > 0 {
				victimSubgraph = splitted[index-1]
			} else {
				victimSubgraph = splitted[len(splitted)-1]
			}
			changedLog = append(changedLog, VictimChanged{
				player:       subgraph.end,
				victimBefore: subgraph.end.Victim,
				victimAfter:  victimSubgraph.start.ToReference(),
			})
			subgraph.end.Victim = victimSubgraph.start.ToReference()
			subgraph.end.WantsNewVictim = false
			c.SavePlayer(subgraph.end)
		}
	} else {
		// There are less than three players who want a new victim. We already
		// know there's at least one unhappy player. Let's have a look at all
		// cases:
		// - 1 player wants a new victim: It has to be the unhappy one. Sadly,
		//   we can't do anything - we can break up the cycle, but then the only
		//   available option is to put it together the way it was before.
		// - 2 players want new victims: Again, let's look at all cases:
		//   - 0 new players, 2 unhappy ones: We can't divide the cycle and put
		//     it back together differently, because that would create two
		//     cycles, which has several drawbacks (see the "Murderous graph"
		//     documentation for more information about why that's a bad idea).
		//   - 1 new player, 1 unhappy one: We can insert the new player between
		//     the unhappy one and its victim.
		if len(newPlayers) == 1 && len(unhappyPlayers) == 1 {
			newPlayer := newPlayers[0]
			unhappyPlayer := unhappyPlayers[0]

			changedLog = append(changedLog, VictimChanged{
				player:       newPlayer,
				victimBefore: newPlayer.Victim,
				victimAfter:  unhappyPlayer.Victim,
			})

			newPlayer.Victim = unhappyPlayer.Victim
			newPlayer.WantsNewVictim = false
			unhappyPlayer.Victim = newPlayer.ToReference()
			unhappyPlayer.WantsNewVictim = false

			c.SavePlayer(newPlayer)
			c.SavePlayer(unhappyPlayer)
		}
	}

	return changedLog, nil
}

// Subgraph of the big cycle.
type Subgraph struct {
	start Player // This player is the victim of an unhappy one.
	end   Player // This player wants a new victim.
}

// splitCycleIntoSubgraphs splits the cycle of players into subgraphs.
func splitCycleIntoSubgraphs(
	c *context.C,
	sampleUnhappyPlayer Player,
) ([]Subgraph, RichError) {
	splitted := make([]Subgraph, 0)
	current := sampleUnhappyPlayer
	var start Player

	newCurrent, err := c.LoadPlayerFromReference(current.Victim)
	current = newCurrent
	if err != nil {
		return make([]Subgraph, 0), err
	}

	for {
		if (start == Player{}) {
			start = current
		}
		if current.WantsNewVictim {
			splitted = append(splitted, Subgraph{start: start, end: current})
			start = Player{}
		}
		if current == sampleUnhappyPlayer {
			break
		}
		current, err = c.LoadPlayerFromReference(current.Victim)
		if err != nil {
			return make([]Subgraph, 0), err
		}
	}

	return splitted, nil
}
