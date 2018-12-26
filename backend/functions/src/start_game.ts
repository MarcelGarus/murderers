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
import { GameCode, Game, GAME_RUNNING, FirebaseAuthToken, User, UserId } from './models';
import { loadGame, queryContains, gameRef, loadPlayersAndIds, allPlayersRef, loadAndVerifyUser, verifyCreator, playerRef } from './utils';
import { shuffleVictims } from './shuffle_victims';
import { log } from 'util';

/// Starts an existing game.
// TODO: make sure not already started
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

  // Verify the creator.
  if (!verifyCreator(game, id, res)) return;
  const user: User = await loadAndVerifyUser(firestore, id, authToken, res);
  if (user === null) return;

  // First, shuffle all the players.
  const players = await loadPlayersAndIds(res, allPlayersRef(firestore, code).get());
  if (!players) return;
  shuffleVictims(players);

  players.forEach(async (player) => {
    await playerRef(firestore, code, player.id).update(player.data);
  })

  // Then, start the game.
  await gameRef(firestore, code).update({
    state: GAME_RUNNING
  });
  
  // Send a response.
  res.send('Game started.');
}
