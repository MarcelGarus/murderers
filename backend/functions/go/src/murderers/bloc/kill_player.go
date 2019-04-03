package bloc

import (
	"murderers/context"
	. "murderers/foundation"
)

// KillPlayer kills the victim of the caller. The victim still needs to confirm
// its death.
func KillPlayer(
	c *context.C,
	id UserID,
	authToken string,
	code GameCode,
	victimID UserID,
) RichError {
	// Note: The victimID may seem like redundant information and that's because
	// it is. In rare cases, Cloud Functions are called multiple times, so we
	// need to ensure that no unintended side effects occur in such a case. If
	// this function is called, then the victim confirms its death and then,
	// this function is called again, no kill request should be sent to the new
	// victim of the player, revealing who's its murderer. That's why we use the
	// victimID to check the victim first.

	// Load and authenticate the murderer. Also, ensure that the victim is the
	// right one for the reason above.
	murderer, err := c.LoadPlayerAndAuthenticate(code, id, authToken)
	if err != nil {
		return err
	} else if murderer.Victim.ID != victimID {
		return VictimNotMatchingError()
	}

	// Kill the victim.
	victim, err := c.LoadPlayerFromReference(murderer.Victim)
	if err != nil {
		return err
	}
	victim.State = PlayerDying
	murdererReference := murderer.ToReference()
	victim.Murderer = murdererReference
	c.SavePlayer(victim)

	// TODO: Send notification to the victim.

	return nil
}
