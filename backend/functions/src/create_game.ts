/// Creates a new game.
///
/// Needs:
/// * Firebase auth in header
/// * a name
/// * ...
///
/// Returns:
/// 200: { code: 'abcd', game: { /* game configuration */ } }
/// 403: {}

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { log } from 'util';
import { Game, GameCode, GAME_NOT_STARTED_YET } from './models';
import { generateRandomString } from './utils';

const GAME_CODE_LENGTH = 4;

/// Creates a new game code.
// TODO: make sure code doesn't already exist
// TODO: use analytics to log how many tries were needed
async function createGameCode(): Promise<GameCode> {
  const code: GameCode = generateRandomString(
    'abcdefghiojklnopqrstuvwxyz0123456789',
    GAME_CODE_LENGTH
  );
  return code;
}

/// Creates a new game.
export async function handleRequest(req: functions.Request, res: functions.Response) {
  log('App is ' + admin.app());
  log('Creating a game.');

  const game: Game = {
    creator: 0,
    name: 'A sample game',
    state: GAME_NOT_STARTED_YET,
    start: Date.now(),
    end: Date.now() + 100,
  };

  const code: GameCode = await createGameCode();

  await admin.app().firestore()
    .collection('games')
    .doc(code)
    .set(game);

  res.set('application/json').send({
    code: code,
    game: game,
  });
}
