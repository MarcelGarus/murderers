package bloc

import (
	"murderers/context"
	. "murderers/foundation"
	"time"
)

// Die kills finishes a player off and provides a new victim to the murderer.
func Die(
	c *context.C,
	me UserID,
	authToken string,
	code GameCode,
	weapon string,
	lastWords string,
) RichError {
	// Load and authenticate the victim. Also, make sure that the victim is
	// dying.
	victim, err := c.LoadPlayerAndAuthenticate(code, me, authToken)
	if err != nil {
		return err
	} else if victim.State != PlayerDying {
		return VictimNotDyingError()
	}

	// Load the murderer.
	murderer, err := c.LoadPlayerFromReference(victim.Murderer)
	if err != nil {
		return err
	}

	// Kill the victim.
	victim.State = PlayerDead
	victim.WantsNewVictim = false
	victim.Death = Death{
		Time:      time.Now(),
		Murderer:  victim.Murderer,
		Weapon:    weapon,
		LastWords: lastWords,
	}
	c.SavePlayer(victim)

	// Give the murderer a new victim. Maybe the murderer can participate in
	// helping other players who want a new victim (i.e. by swapping the
	// victims).
	murderer.Victim = victim.Victim
	murderer.Kills++
	murderer.WantsNewVictim = true
	c.SavePlayer(murderer)

	_, err = satisfyPlayers(c, code)
	if err != nil {
		return err
	}
	murderer, err = c.LoadPlayer(code, murderer.User.ID) // Reload the murderer.
	if err != nil {
		return err
	}
	murderer.WantsNewVictim = false
	c.SavePlayer(murderer)

	// TODO: Notify players that their victims changed.

	return nil
}
