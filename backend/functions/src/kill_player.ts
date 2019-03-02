/// Kills a player. The victim still needs to confirm its death.
///
/// Needs:
/// * user [id]
/// * [authToken]
/// * game [code]
///
/// Returns either:
/// 200: Kill request sent to victim.
/// 403: Access denied.
/// 404: Game not found.
/// 500: Corrupt data.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, FirebaseAuthToken, PLAYER_DYING, User, UserId } from './models';
import { loadPlayer, queryContains, playerRef, loadAndVerifyUser, loadUser } from './utils';
import { log } from 'util';

/// Offers webhook for killing the victim.
export async function handleRequest(
  req: functions.Request,
  res: functions.Response
): Promise<void> {
  if (!queryContains(req.query, [
    'id', 'authToken', 'code'
  ], res)) return;

  const firestore = admin.app().firestore();
  const id: UserId = req.query.id;
  const authToken: FirebaseAuthToken = req.query.authToken;
  const code: GameCode = req.query.code;

  log(code + ': Player ' + id + ' kills his/her victim.');

  // Load the user and verify Firebase Auth token.
  const user: User = await loadAndVerifyUser(firestore, id, authToken, res);
  if (user === null) return;

  // Load the murderer.
  const murderer = await loadPlayer(res, firestore, code, id);
  if (murderer === null) return;

  // Kill the victim.
  if (murderer.victim === null) return;
  await playerRef(firestore, code, murderer.victim).update({
    state: PLAYER_DYING,
    murderer: id,
  });

  // Load the victim.
  const victimUser = await loadUser(firestore, murderer.victim, res);

  // Send response.
  res.send('Kill request sent to victim.');

  // Send notification to the victim.
  admin.messaging().send({
    notification: {
      title: 'You are dying!',
      body: 'Did ' + user.name + ' just kill you?',
    },
    android: {
      priority: 'high',
      notification: {
        color: '#ff0000',
      },
    },
    token: victimUser.messagingToken,
  }).then((response) => {
    log('Successfully sent message. Message id: ' + response);
  }).catch((error) => {
    log('Error sending message: ' + error);
  });
}
