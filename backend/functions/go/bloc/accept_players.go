package bloc

import (
	"fundamentals"
	"utils"
)

func AcceptPlayers(
	f Fundamentals,
	myId UserId,
	authToken string,
	gameCode GameCode,
	playersToAccept []Player
) ErrorWithStatus {
	var creator User
	var game Game

	// Make sure there are players to accept.
	if playersToAccept.length == 0 {
		return BadRequestError("No players to accept.")
	}

	// Load the creator and the game.
	if creator, game, err = loadGameAndVerifiedCreator(f, me, authToken, gameCode); err != nil {
		return nil, err
	}

	// Make sure all those users are actually players in the game and they
	// weren't accepted yet.
	
}

  // Make sure all those users are actually players in the game and they weren't
  // accepted yet.
  for (const acceptId of accept) {
    const player: Player = await loadPlayer(res, firestore, code, acceptId);
    if (player === null) return;
    if (player.state !== PLAYER_JOINING) {
      res.status(CODE_ILLEGAL_STATE)
        .send('Player ' + acceptId + ' was already accepted.');
      return;
    }
  }

  // Accept all the players by changing their state.
  const batch = firestore.batch();
  for (const acceptId of accept) {
    batch.update(playerRef(firestore, code, acceptId), {
      state: PLAYER_ALIVE,
      wantsNewVictim: true,
    });
  }
  await batch.commit();
  
  // Send a response.
  res.send('Players accepted.');

  // Send notifications.
  for (const acceptId of accept) {
    const acceptUser: User = await loadUser(firestore, acceptId, null);
    if (acceptUser === null) {
      log('Accepted user ' + acceptId + ' not found.');
      continue;
    }

    // Notify all the accepted players that they got accepted.
    admin.messaging().send({
      notification: {
        title: 'You got accepted',
        body: 'You just joined the game "' + game.name + '".'
      },
      android: {
        priority: 'high',
        collapseKey: 'game_' + code,
        notification: { color: '#ff0000' }
      },
      token: acceptUser.messagingToken
    }).catch((error) => {
      log('Error while sending "you got accepted" message: ' + error);
    });

    // Notify all other players that they got accepted.
    // TODO: only notify the other players
    admin.messaging().send({
      notification: {
        title: acceptUser.name + ' just joined the game',
        body: ''
      },
      android: {
        priority: 'normal',
        collapseKey: 'game_' + code,
        notification: { color: '#ff0000' }
      },
      token: "'game_" + code + "' in topics && 'player_joined' in topics"
    }).catch((error) => {
      log('Error while sending "a new player joined" message: ' + error);
    });
  }