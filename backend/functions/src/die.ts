/// A player dies by confirming his/her death.
///
/// Needs:
/// * [me]
/// * [authToken]
/// * [game]
/// * [weapon]
/// * [lastWords]
///
/// Returns either:
/// 200: You died.
/// 403: Access denied.
/// 404: Game not found.
/// 500: Corrupt data.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, FirebaseAuthToken, PLAYER_DYING, PLAYER_DEAD, PLAYER_ALIVE, UserId, User, Player } from './models';
import { loadPlayer, queryContains, playerRef, loadPlayersAndIds, loadAndVerifyUser, allPlayersRef } from './utils';
import { shuffleVictims } from './shuffle_victims';
import { log } from 'util';
import { CODE_ILLEGAL_STATE } from './constants';

/// Offers webhook for dying.
export async function handleRequest(
  req: functions.Request,
  res: functions.Response
): Promise<void> {
  if (!queryContains(req.query, [
    'me', 'authToken', 'game', 'weapon', 'lastWords'
  ], res)) return;

  const firestore = admin.app().firestore();
  const authToken: FirebaseAuthToken = req.query.authToken;
  const code: GameCode = req.query.game;
  const id: UserId = req.query.me;
  const weapon: string = req.query.weapon;
  const lastWords: string = req.query.lastWords;

  log(code + ': Player ' + id + ' dies with honor.');

  // Verify the user.
  const user: User = await loadAndVerifyUser(firestore, id, authToken, res);
  if (user === null) return;

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

  // Send response.
  res.send('You died.');

  // Send a notification to the murderer.
  admin.messaging().send({
    notification: {
      title: user.name + ' just died!',
      body: 'Killed with ' + weapon + '. Last words: "' + lastWords + '"',
    },
    android: {
      priority: 'normal',
      collapseKey: 'player_killed_' + code,
      notification: {
        color: '#ff0000',
      },
    },
    condition: "'game_" + code + "' in topics && 'deaths' in topics",
  }).then((response) => {
    log('Successfully sent message. Message id: ' + response);
  }).catch((error) => {
    log('Error sending message: ' + error);
  });

  // Send a notification to _all_ subscribed users.
  admin.messaging().send({
    notification: {
      title: user.name + ' just died!',
      body: 'Killed with ' + weapon + '. Last words: "' + lastWords + '"',
    },
    android: {
      priority: 'normal',
      collapseKey: 'player_killed_' + code,
      notification: {
        color: '#ff0000',
      },
    },
    condition: "'game_" + code + "' in topics && 'deaths' in topics",
  }).then((response) => {
    log('Successfully sent message. Message id: ' + response);
  }).catch((error) => {
    log('Error sending message: ' + error);
  });
}
