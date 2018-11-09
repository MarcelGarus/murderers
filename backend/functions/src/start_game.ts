/// Starts an existing game.
///
/// Needs:
/// * a Firebase auth in header
/// * a game id
///
/// Returns either:
/// 200: Game started.
/// 403: Access denied.
/// 404: Game not found.
/// 500: Game corrupt.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, Game, PlayerId, Player, GAME_RUNNING } from './models';
import { loadGame, GAME_NOT_FOUND, GAME_CORRUPT, GAME_STARTED } from './utils';

/// Starts an existing game.
// TODO: check access
export async function handleRequest(req: functions.Request, res: functions.Response) {
  console.log('Request query is ' + JSON.stringify(req.query));

  // Get a reference to the database and the game code.
  const db = admin.app().firestore();
  const code: GameCode = req.query.code + '';
  let game: Game;

  // Try to load the game.
  try {
    game = await loadGame(db, code);
  } catch (error) {
    console.log("Starting the game failed, because the game couldn't be loaded. Error is:");
    console.log(error);

    if (true) { // TODO: check error message
      res.status(404).send(GAME_NOT_FOUND);
    } else {
      res.status(500).send(GAME_CORRUPT);
    }
  }

  // Game loaded successfully. Now start it.
  console.log('Game to start is ' + game);

  await db
    .collection('games')
    .doc(code)
    .update({
      state: GAME_RUNNING
    });

  // TODO: set victims of players.
  const snapshot = await db
    .collection('games')
    .doc(code)
    .collection('players')
    .get();

  console.log('Players to shuffle and connect are ' + JSON.stringify(snapshot));
  res.send(snapshot);

  // Send back the player id and the authToken.
  //res.set('application/json').send(GAME_STARTED);
}
