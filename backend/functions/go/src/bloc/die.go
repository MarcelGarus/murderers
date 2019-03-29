package bloc

import (
	"context"
)

func Die(c Context, me UserId, authToken string, code GameCode, weapon string, lastWords string) {
  var murderer Player
  var victim Player
	
  // Load and validate the murderer.
  if murderer, err := c.s.LoadAuthenticatedPlayer(code, me, authToken); err != nil {
    return nil, err
  }

	// Verify that the victim is dying.
	if victim, err := player.Victim.Get(); err != nil {
    return nil, err
  } else if victim.State != PlayerDying {
    return nil, VictimNotDyingError()
  }
  
  // Load players who wait for a victim to be assigned to them.
  if newPlayers, err = c.s.LoadNewPlayers(); err != nil {
    return nil, err
  }
  if playersWhoWantNewVictim, err = c.s.LoadPlayersWhoWantNewVictim(); err != nil {
    return nil, err
  }

  // Shuffle new players.
  shuffleVictims(newPlayers);

  if (newPlayers.length > 0) {
    murderer.victim = newPlayers[0].id;
    newPlayers[0].data.victim = victim.victim;
  } else {
    murderer.victim = victim.victim;
  }

  // Shuffle players who want a new victim.
  // We do that
  if len(playersWhoWantNewVictim) >= 3 {
    var splitted [](Player, Player)
    var current Player = murderer
    var start Player

    loop: for {
      if start == nil {
        start = current
      }
      if current.wantsNewVictim {
        splitted.append((start, current))
        start = nil
      }
      if current == murderer {
        break loop
      }
      current = current.victim.Get()
    }
    if !current.wantsNewVictim {
      splitted[0][0] = current
    }

    for i = 0; i < len(splitted); i++ {
      if i > 0 {
        splitted[i][1].victim = splitted[i-1][0]
      } else {
        splitted[i][1].victim = splitted[len(splitted)-1][0]
      }
    }
  }
}
