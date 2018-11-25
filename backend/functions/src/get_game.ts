/// Returns a game's state.
///
/// Needs:
/// * a game code
///
/// Returns either:
/// 200: { id: 'abcdefghiojklmonop', authToken: 'dfsiidfsd' }
/// 404: Game not found.
/// 500: Game corrupt.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, Game, Player, isPlayer } from './models';
import { loadGame } from './utils';

/// Returns a game's state.
export async function handleRequest(req: functions.Request, res: functions.Response) {
  console.log('Request query is ' + JSON.stringify(req.query));

  // Get a reference to the database and the game code.
  const db = admin.app().firestore();
  const code: GameCode = req.query.code + '';
  let game: Game;

  console.log('Getting the game ' + code + '.');

  // Try to load the game.
  try {
    game = await loadGame(db, code);
  } catch (error) {
    console.log("The game couldn't be loaded. Error is:");
    console.log(error);

    if (true) { // TODO: check error message
      res.status(404).send('Game not found.');
    } else {
      res.status(500).send('Game corrupt.');
    }
  }

  // Load the players.
  const snapshot = await db
    .collection('games')
    .doc(code)
    .collection('players')
    .get();

  let playerIds: string[] = [];
  let players: Player[] = [];
  
  for (let doc of snapshot.docs) {
    const id = doc.id;
    const data = doc.data();

    console.log("Player has data " + JSON.stringify(data));

    if (!isPlayer(data)) {
      res.status(500).send('Player corrupt.');
      return;
    } else {
      playerIds.push(id);
      players.push(data as Player);
    }
  }

  console.log("Players are " + JSON.stringify(players));

  // Send back the game's state.
  res.set('application/json').send({
    name: game.name,
    state: game.state,
    created: game.created,
    end: game.end,
    players: players.map((value, index, _) => {
      return {
        id: playerIds[index],
        name: value.name,
        death: value.death
      };
    })
  });
}
