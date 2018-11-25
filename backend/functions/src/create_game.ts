/// Creates a new game.
///
/// Needs:
/// * Firebase auth in header
/// * a game name
///
/// Returns either:
/// 200: { code: 'abcd' }
/// 403: Access denied.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { log } from 'util';
import { Game, GameCode, GAME_NOT_STARTED_YET } from './models';
import { generateRandomString } from './utils';

const GAME_CODE_CHARS = 'abcdefghiojklnopqrstuvwxyz0123456789';
const GAME_CODE_LENGTH = 4;

/// Creates a new game code.
// TODO: make sure code doesn't already exist
// TODO: use analytics to log how many tries were needed
async function createGameCode(): Promise<GameCode> {
  const code: GameCode = generateRandomString(
    GAME_CODE_CHARS,
    GAME_CODE_LENGTH
  );
  return code;
}

/// Creates a new game.
/// TODO: make sure the user signed in with their Google account.
export async function handleRequest(req: functions.Request, res: functions.Response) {
  const name: string = req.query.name + '';
  const messagingToken: string = req.query.messagingToken + '';

  log('Creating a game named ' + name + '. Creators messaging token: ' + messagingToken);

  const game: Game = {
    creator: 0,
    name: name,
    state: GAME_NOT_STARTED_YET,
    created: Date.now(),
    end: Date.now() + 100,
  };

  const code: GameCode = await createGameCode();

  await admin.app().firestore()
    .collection('games')
    .doc(code)
    .set(game);

  // Send the game code back.
  res.set('application/json').send({
    code: code,
  });
}
