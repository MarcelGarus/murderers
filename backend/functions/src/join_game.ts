/// Joins a player to a game.
///
/// Needs:
/// * a player name
///
/// Returns:
/// 200: { id: 'abcdefghiojklmonop', auth: 'dfsiidfsd' }

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, Game, PlayerId, AuthToken, Player } from './models';
import { loadGame, generateRandomString } from './utils';
import { isUndefined } from 'util';

const PLAYER_ID_LENGTH = 2;
const AUTH_TOKEN_LENGTH = 16;

/// Creates a new player id.
// TODO: make sure id doesn't already exist
// TODO: use analytics to log how many tries were needed
async function createPlayerId(): Promise<PlayerId> {
  const id: PlayerId = generateRandomString(
    'abcdefghiojklnopqrstuvwxyz0123456789',
    PLAYER_ID_LENGTH
  );
  return id;
}

/// Creates a new auth token.
function createAuthToken(): AuthToken {
  return generateRandomString(
    'abcdefghiojklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
    AUTH_TOKEN_LENGTH
  );
}

/// Joins a player to a game.
export async function handleRequest(req: functions.Request, res: functions.Response) {
  console.log('Request is ' + JSON.stringify(req));
  console.log('Joining the game.');

  const db = admin.app().firestore();
  const code: GameCode = 'abcd'; // TODO: get from params
  const game: Game = await loadGame(db, code);

  if (isUndefined(game)) {
    console.log("Joining the game failed, because the game couldn't be loaded.");
    res.status(500).set('application/json').send('Joining the game failed.');
    return;
  }

  console.log('Game to join is ' + game);

  const player: Player = {
    authToken: createAuthToken(),
    name: 'Marcel',
    isAlive: true,
    victim: ''
  };

  const id: PlayerId = await createPlayerId();

  await db
    .collection('games')
    .doc(code)
    .collection('players')
    .doc(id)
    .set(player);

  res.set('application/json').send(player);
}
