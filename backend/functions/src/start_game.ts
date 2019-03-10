/// Starts an existing game.
///
/// Needs:
/// * user [id]
/// * [authToken]
/// * game [code]
///
/// Returns either:
/// 200: Game started.
/// 403: Access denied.
/// 404: Game not found.
/// 500: Game corrupt.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, Game, GAME_RUNNING, FirebaseAuthToken, User, UserId, GAME_NOT_STARTED_YET } from './models';
import { loadGame, queryContains, gameRef, loadPlayersAndIds, allPlayersRef, loadAndVerifyUser, verifyCreator, playerRef } from './utils';
import { shuffleVictims } from './shuffle_victims';
import { log } from 'util';
import { CODE_ILLEGAL_STATE, GAME_MINIMUM_PLAYERS } from './constants';

export async function handleRequest(req: functions.Request, res: functions.Response) {
  if (!queryContains(req.query, [
    'id', 'authToken', 'code'
  ], res)) return;

  const firestore = admin.app().firestore();
  const id: UserId = req.query.id;
  const authToken: FirebaseAuthToken = req.query.authToken;
  const code: GameCode = req.query.code;

  log(code + ': Starting the game.');

  // Load the game.
  const game: Game = await loadGame(res, firestore, code);
  if (game === null) return;

  // Make sure the game didn't start yet.
  if (game.state !== GAME_NOT_STARTED_YET) {
    const errText = 'The game already started.';
    res.status(CODE_ILLEGAL_STATE).send(errText);
    log(errText);
    return;
  }

  // Verify the creator.
  if (!verifyCreator(game, id, res)) return;
  const user: User = await loadAndVerifyUser(firestore, id, authToken, res);
  if (user === null) return;

  // Get all the players and make sure there are enough.
  const players = await loadPlayersAndIds(res, allPlayersRef(firestore, code).get());
  if (!players) return;
  if (players.length < GAME_MINIMUM_PLAYERS) {
    const errText = 'There are only ' + players.length + ' players, but '
      + GAME_MINIMUM_PLAYERS + ' are required to start the game.'
    res.status(CODE_ILLEGAL_STATE).send(errText);
    log(errText);
    return;
  }
  
  // Shuffle all the players and change the game state.
  const batch = firestore.batch();
  shuffleVictims(players);
  players.forEach((player) => {
    batch.update(playerRef(firestore, code, player.id), player.data);
  });
  batch.update(gameRef(firestore, code), { state: GAME_RUNNING });
  await batch.commit();
  
  // Send a response.
  res.send('Game started.');

  // Notify everyone that the game started.
  admin.messaging().send({
    notification: {
      title: 'The game just started',
      body: 'Get ready for an exciting time!',
    },
    android: {
      priority: 'normal',
      collapseKey: 'game_' + code,
      notification: { color: '#ff0000' },
    },
    condition: "'game_" + code + "' in topics",
  }).catch((error) => {
    log('Error while sending "game started" message: ' + error);
  });
}
