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
import { GameCode, Game, Player, GAME_RUNNING, isPlayer } from './models';
import { loadGame, shuffle, GAME_NOT_FOUND, GAME_CORRUPT } from './utils';

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

  const snapshot = await db
    .collection('games')
    .doc(code)
    .collection('players')
    .get();

  // Save all players.
  const players: {id, data: Player}[] = [];

  snapshot.forEach(doc => {
    const data = doc.data();
    console.log(doc.id, '=>', data);

    if (isPlayer(data)) {
      players.push({
        id: doc.id,
        data: data as Player
      });
    } else {
      console.log('Is not a player: ' + data);
    }
  })

  console.log('Players to shuffle and connect are ' + JSON.stringify(players));

  // Set the player's victims randomly.
  shuffle(players);
  console.log('Shuffled players are ' + JSON.stringify(players));
  players.forEach((player, index) => {
    console.log('Setting the victim of player #' + index + ' (' + JSON.stringify(player) + ')');
    if (index === 0) {
      player.data.victim = players[players.length - 1].id;
    } else {
      player.data.victim = players[index - 1].id;
    }
  });
  players.forEach(async (player) => {
    await db
      .collection('games')
      .doc(code)
      .collection('players')
      .doc(player.id)
      .set(player.data);
  });

  res.send('success');
}
