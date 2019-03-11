/// Joins a player to a game. The game creator will still need to approve of the
/// new player for the joining to have any effect.
///
/// Needs:
/// * [me]
/// * [authToken]
/// * [game]
///
/// Returns either:
/// 200: Joined.
/// 400: Bad request.
/// 403: Access denied.
/// 404: Game not found.
/// 500: Game corrupt.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, Game, UserId, Player, FirebaseAuthToken, User, PLAYER_JOINING, PLAYER_ALIVE } from './models';
import { loadGame, playerRef, queryContains, loadAndVerifyUser, loadUser } from './utils';
import { log } from 'util';
import { CODE_ILLEGAL_STATE } from './constants';

/// Joins a player to a game.
export async function handleRequest(
  req: functions.Request,
  res: functions.Response
): Promise<void> {
  if (!queryContains(req.query, [
    'me', 'authToken', 'game'
  ], res)) return;

  const firestore = admin.app().firestore();
  const id: UserId = req.query.me;
  const authToken: FirebaseAuthToken = req.query.authToken;
  const code: GameCode = req.query.game;

  log(code + ': ' + id + ' joins.');

  // Load and verify the user.
  const user: User = await loadAndVerifyUser(firestore, id, authToken, res);
  if (user === null) return;

  // Load the game.
  const game: Game = await loadGame(res, firestore, code);
  if (game === null) return;

  // Make sure user didn't already join.
  const existingPlayer = await playerRef(firestore, code, id).get();
  if (existingPlayer.exists) {
    const errText = 'You already joined this game.';
    res.status(CODE_ILLEGAL_STATE).send(errText);
    return;
  }

  // Create the player.
  const isCreator: boolean = (id === game.creator);
  const player: Player = {
    state: isCreator ? PLAYER_ALIVE : PLAYER_JOINING,
    kills: 0,
    murderer: null,
    victim: null,
    wantsNewVictim: isCreator,
    death: null
  };

  await playerRef(firestore, code, id).set(player);

  // Send response.
  res.set('application/json').send('Joined.');

  // Get the creator.
  const creator: User = await loadUser(firestore, game.creator, res);
  if (creator === null) {
    log("Creator couldn't be found and notified.");
    return;
  }

  // Send a notification to the creator.
  admin.messaging().send({
    notification: {
      title: user.name + ' wants to join the game',
      body: 'Tap to go to the admin panel.',
    },
    android: {
      priority: 'high',
      collapseKey: 'game_' + code + '_admin',
      notification: {
        color: '#ff0000',
      },
    },
    token: creator.messagingToken
  }).catch((error) => {
    log('Error sending message to creator: ' + error);
  });
}
