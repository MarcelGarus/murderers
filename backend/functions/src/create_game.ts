/// Creates a new game.
///
/// Needs:
/// * [me]
/// * [authToken]
/// * [end] time
///
/// Returns either:
/// 200: { code: 'abcd' }
/// 400: Bad request.
/// 403: Access denied.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { log } from 'util';
import { Game, GameCode, GAME_NOT_STARTED_YET, FirebaseAuthToken, User } from './models';
import { generateRandomString, gameRef, queryContains, loadAndVerifyUser } from './utils';
import { GAME_CODE_CHARS, GAME_CODE_LENGTH } from './constants';

/// Creates a new game code.
async function createGameCode(
  firestore: FirebaseFirestore.Firestore
): Promise<GameCode> {
  let code: GameCode = '';
  let tries = 0;

  while (true) {
    code = generateRandomString(GAME_CODE_CHARS, GAME_CODE_LENGTH);
    tries++;

    const snapshot = await gameRef(firestore, code).get();
    if (!snapshot.exists) break;
  }

  log(code + ': It took ' + tries + ' tries to create this game code.');
  return code;
}

/// Offers webhook for creating a new game.
export async function handleRequest(
  req: functions.Request,
  res: functions.Response
): Promise<void> {
  if (!queryContains(req.query, [
    'me', 'authToken', 'name', 'end'
  ], res)) return;

  const firestore = admin.app().firestore();
  const id = req.query.me;
  const authToken: FirebaseAuthToken = req.query.authToken;
  const name: string = req.query.name;
  const end: number = parseInt(req.query.end);

  log(id + 'creates a game named ' + name + '.');

  // Load and verify the user.
  const user: User = await loadAndVerifyUser(firestore, id, authToken, res);
  if (user === null) return;

  // Create the game.
  // TODO: sanitize name, make sure start and end dates are valid
  const game: Game = {
    name: name,
    state: GAME_NOT_STARTED_YET,
    creator: id,
    created: Date.now(),
    end: end,
  };

  const code: GameCode = await createGameCode(firestore);

  await gameRef(firestore, code).set(game);

  log(code + ': Game created.');

  // Send back the code.
  res.set('application/json').send({
    code: code,
    name: game.name,
    created: game.created,
    end: game.end
  });
}
