/// A player dies by confirming his/her death.
///
/// Needs:
/// * user [id]
/// * [authToken]
/// * game [code]
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
import { GameCode, FirebaseAuthToken, PLAYER_DYING, PLAYER_DEAD, PLAYER_WAITING, PLAYER_ALIVE, UserId, User, Player } from './models';
import { loadPlayer, queryContains, playerRef, loadPlayersAndIds, loadAndVerifyUser, allPlayersRef } from './utils';
import { shuffleVictims } from './shuffle_victims';
import { log } from 'util';

/// Offers webhook for dying.
export async function handleRequest(
  req: functions.Request,
  res: functions.Response
): Promise<void> {
  if (!queryContains(req.query, [
    'id', 'authToken', 'code', 'weapon', 'lastWords'
  ], res)) return;

  const firestore = admin.app().firestore();
  const authToken: FirebaseAuthToken = req.query.authToken;
  const code: GameCode = req.query.code;
  const id: UserId = req.query.id;
  const weapon: string = req.query.weapon;
  const lastWords: string = req.query.lastWords;

  log(code + ': Player ' + id + ' dies with honor.');

  // Verify the user.
  const user: User = await loadAndVerifyUser(firestore, id, authToken, res);
  if (user === null) return;

  // Verify the victim's dying.
  const victim: Player = await loadPlayer(res, firestore, code, id);
  if (victim === null) return;
  if (victim.state !== PLAYER_DYING || victim.murderer === null) return;

  // Load the murderer.
  const murderer: Player = await loadPlayer(res, firestore, code, victim.murderer);
  if (murderer === null) return;

  // Load all waiting players.
  const snapshotPromise = allPlayersRef(firestore, code)
    .where('state', '==', PLAYER_WAITING)
    .get();
  const waiting = await loadPlayersAndIds(res, snapshotPromise);
  if (waiting === null) return;

  // All players that are waiting as well as the murderer get new victims.
  shuffleVictims(waiting);

  if (waiting.length > 0) {
    murderer.victim = waiting[0].id;
    waiting[0].data.victim = victim.victim;
  } else {
    murderer.victim = victim.victim;
  }

  // Update waiting players.
  for (const player of waiting) {
    await playerRef(firestore, code, player.id).update(player.data);
  }

  // Update the murderer.
  await playerRef(firestore, code, victim.murderer).update({
    state: PLAYER_ALIVE,
    victim: murderer.victim,
    wasOutsmarted: false,
    kills: murderer.kills + 1,
  });

  // Update the victim.
  await playerRef(firestore, code, id).update({
    state: PLAYER_DEAD,
    victim: null,
    wasOutsmarted: false,
    deaths: {
      time: Date.now(),
      murderer: victim.murderer,
      weapon: weapon,
      lastWords: lastWords
    }
  });

  // Send response.
  res.send('You died.');

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
