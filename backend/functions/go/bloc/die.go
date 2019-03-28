package bloc

import (
	""
)

func Die(s Storage, me UserId, authToken string, gameCode GameCode, weapon string, lastWords string) {
	var user User
	var player Player
	
	// Load and validate the user.
	if user, err := s.LoadUser(creator); err != nil {
		return game, err
	} else if ok = validateUser(user, authToken); !ok {
		return game, errors.New("create_game: authentication failed")
	}

	// Verify that the victim is dying.
	if player, err := s.LoadPlayer(gameCode, )
}

  // Verify that the victim is dying.
  const victim: Player = await loadPlayer(res, firestore, code, id);
  if (victim === null) return;
  if (victim.state !== PLAYER_DYING || victim.murderer === null) {
    res.status(CODE_ILLEGAL_STATE).send('You are not dying!');
    return;
  }

  // Load the murderer.
  const murderer: Player = await loadPlayer(res, firestore, code, victim.murderer);
  if (murderer === null) return;

  // Load players who wait for a victim to be assigned to them.
  const newPlayersPromise = allPlayersRef(firestore, code)
    .where('state', '==', PLAYER_ALIVE)
    .where('victim', '==', null)
    .get();
  const newPlayers = await loadPlayersAndIds(res, newPlayersPromise);
  if (newPlayers === null) return;

  // All players who want new victims are shuffled.
  shuffleVictims(newPlayers);

  if (newPlayers.length > 0) {
    murderer.victim = newPlayers[0].id;
    newPlayers[0].data.victim = victim.victim;
  } else {
    murderer.victim = victim.victim;
  }

  // Update waiting players.
  for (const player of newPlayers) {
    await playerRef(firestore, code, player.id).update(player.data);
  }

  // Update the murderer.
  await playerRef(firestore, code, victim.murderer).update({
    state: PLAYER_ALIVE,
    victim: murderer.victim,
    isOutsmarted: false,
    kills: murderer.kills + 1,
  });

  // Update the victim.
  await playerRef(firestore, code, id).update({
    state: PLAYER_DEAD,
    victim: null,
    wantsNewVictim: false,
    death: {
      time: Date.now(),
      murderer: victim.murderer,
      weapon: weapon,
      lastWords: lastWords
    }
  });
