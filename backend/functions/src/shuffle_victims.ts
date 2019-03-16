/// Shuffle all the players of a game.
///
/// Needs:
/// * [me]
/// * [authToken]
/// * game [code]
/// * whether to shuffle [onlyOutsmartedPlayers]
///
/// Returns either:
/// 200: Players shuffled.
/// 400: Bad request.
/// 403: Access denied.
/// 404: Game not found.
/// 500: Game corrupt.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, Player, FirebaseAuthToken, User, UserId, PLAYER_ALIVE } from "./models";
import { shuffle, loadPlayersAndIds, playerRef, queryContains, loadGame, allPlayersRef, verifyCreator, loadAndVerifyUser } from './utils';
import { log } from 'util';

/// Shuffles the given players' as victims locally and in-place.
export function shuffleVictims(
  players: Array<{id: string, data: Player}>
): void {
  // Actually shuffle the players.
  log('Shuffling ' + players.length + ' players.');

  shuffle(players);

  // Update the players' victims locally.
  players.forEach((player, index) => {
    player.data.victim = players[
      (index > 0) ? (index - 1) : (players.length - 1)
    ].id;
    player.data.state = PLAYER_ALIVE;
    log('Player ' + player.id + ' now has victim ' + player.data.victim + '.');
  });
}

/// Offers webhook for shuffling victims.
// TODO: offer option to not shuffle dead players
export async function handleRequest(
  req: functions.Request,
  res: functions.Response
): Promise<void> {
  if (!queryContains(req.query, [
    'id', 'authToken', 'code', 'onlyOutsmarted'
  ], res)) return;

  const firestore = admin.app().firestore();
  const id: UserId = req.query.me;
  const authToken: FirebaseAuthToken = req.query.authToken;
  const code: GameCode = req.query.code;
  const onlyOutsmartedPlayers: boolean = (req.query.onlyOutsmartedPlayers === 'true');

  log(code + ': Shuffling players. Only outsmarted ones? ' + onlyOutsmartedPlayers);

  // Load the game.
  const game = await loadGame(res, firestore, code);
  if (game === null) return;

  // Verify the creator.
  if (!verifyCreator(game, id, res)) return;
  const user: User = await loadAndVerifyUser(firestore, id, authToken, res);
  if (user === null) return;

  // Get all the players that should be shuffled.
  let playersRef: any = allPlayersRef(firestore, code);

  /*if (onlyAlivePlayers) {
    playersRef = playersRef.where('state', '==')
  }*/
  if (onlyOutsmartedPlayers) {
    playersRef = playersRef.where('wasOutsmarted', '==', true);
  }

  const players: Array<{id: string, data: Player}>
    = await loadPlayersAndIds(res, playersRef.get());
  if (players === null) return;

  // Shuffle players.
  shuffleVictims(players);

  players.forEach(async (player) => {
    await playerRef(firestore, code, player.id).update(player.data);
  });

  // Send response.
  res.send('Players shuffled.');
}
