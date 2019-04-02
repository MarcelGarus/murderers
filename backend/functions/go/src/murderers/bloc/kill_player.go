package bloc

import (
	."murderers/foundation"
	"murderers/context"
)

// KillPlayer kills the victim of the caller. The victim still needs to confirm
// its death.
func KillPlayer(
	c context.C,
	id UserID,
	authToken string,
	code GameCode,
	victimID UserID,
) RichError {
	// Note: The victimID may seem like redundant information and that's because
	// it is. In rare cases, Cloud Functions may be called multiple times, so we
	// need to ensure that no unintended side effects occur in such a case. If
	// this function is called, then the victim confirms its death and then,
	// this function is called again, no kill request should be sent to the new
	// victim of the player, revealing who's its murderer. That's why we use the
	// victimID to check the victim first.

	// Load and authenticate the murderer. Also, ensure that the victim is the
	// right one for the reason above.
	murderer, err := c.LoadAndAuthenticatePlayer(code, id, authToken)
	if err != nil {
		return err
	} else if murderer.Victim.ID != victimID {
		return VictimNotMatchingError()
	}

	// Kill the victim.
	victim, err := c.GetPlayer(murderer.Victim)
	if err != nil {
		return err
	}
	victim.State = PlayerDying
	victim.Murderer = murderer.ToReference()
	c.Storage.SavePlayer(victim)
}

  // Kill the victim.
  await playerRef(firestore, code, murderer.victim).update({
    state: PLAYER_DYING,
    murderer: id,
  });

  // Send response.
  res.send('Kill request sent to victim.');

  // Send notification to the victim.
  const victimUser = await loadUser(firestore, murderer.victim, null);
  if (victimUser === null) {
    log("This is strange, the victim doesn't exist.");
    return;
  }
  admin.messaging().send({
    notification: {
      title: 'You are dying',
      body: 'Did ' + user.name + ' just kill you?',
    },
    android: {
      priority: 'high',
      notification: {
        color: '#ff0000',
      },
    },
    token: victimUser.messagingToken
  }).catch((error) => {
    log('Error sending message: ' + error);
  });
}
