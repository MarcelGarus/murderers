/// Joins a player to a game.
///
/// Needs:
/// * user [id]
/// * [authToken]
/// * game [code]
///
/// Returns either:
/// 200: Joined.
/// 400: Bad request.
/// 403: Access denied.
/// 404: Game not found.
/// 500: Game corrupt.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, Game, UserId, Player, FirebaseAuthToken, PLAYER_WAITING, User } from './models';
import { loadGame, playerRef, queryContains, loadAndVerifyUser } from './utils';
import { log } from 'util';

/// Joins a player to a game.
// TODO: Prevent player from joining twice.
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

  log(code + ': ' + id + ' joins.');

  // Load and verify the user.
  const user: User = await loadAndVerifyUser(firestore, id, authToken, res);
  if (user === null) return;

  // Load the game.
  const game: Game = await loadGame(res, firestore, code);
  if (game === null) return;

  // Create the player.
  const player: Player = {
    state: PLAYER_WAITING,
    murderer: null,
    victim: null,
    wasOutsmarted: false,
    deaths: [],
    kills: 0
  };

  await playerRef(firestore, code, id).set(player);

  // Send back the id.
  res.set('application/json').send('Joined.');

  // TODO: Also send a notification to _all_ members of the game that opted in for notifications about new players.
  admin.messaging().send({
    notification: {
      title: 'Someone just joined the game ' + code,
      body: 'Say hi by killing ' + id + '!',
    },
    android: {
      priority: 'normal',
      collapseKey: 'someone_joins_' + code,
      notification: {
        color: '#ff0000',
      },
    },
    token: 'emd1IxAjbQg:APA91bF7MNO65rvy3Pg_XGEkJPHNdCSLpmahmreQYYRVEAzsIXaeg2XQNdRUHphERXzAX8WTRXnEEdisiMNsWoTQF-ee5HHDN8Gn1TIfF0MVxDbWso21JxDJt5-9-QtVUc2Jfe6EJYq7'
  }).then((response) => {
    log('Successfully sent message. Message id: ' + response);
  }).catch((error) => {
    log('Error sending message: ' + error);
  });
}
