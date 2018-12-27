/// Returns a game's state.
///
/// Needs:
/// * game [code]
/// Optional:
/// * user [id]
/// * [authToken]
///
/// Returns either:
/// 200: {
///   name: 'The game\'s name',
///   state: GameState.RUNNING,
///   created: 'Some google id',
///   end: 2222-12-22,
///   players: [
///     {
///       id: 'player-id',
///       name: 'Marcel',
///       death: {
///         ...
///       }
///     },
///     ...
///   ]
/// }
/// 404: Game not found.
/// 500: Game corrupt.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, Game, Player, UserId, FirebaseAuthToken, User } from './models';
import { loadGame, loadPlayersAndIds, allPlayersRef, queryContains, loadAndVerifyUser, loadUser } from './utils';

/// Returns a game's state.
// TODO: handle no id and code given
export async function handleRequest(req: functions.Request, res: functions.Response) {
  if (!queryContains(req.query, [
    'code'
  ], res)) return;

  const firestore = admin.app().firestore();
  let id: UserId = req.query.id;
  let authToken: FirebaseAuthToken = req.query.authToken;
  const code: GameCode = req.query.code + '';

  // Load the game.
  const game: Game = await loadGame(res, firestore, code);
  if (game === null) return;

  // Load the user.
  const user: User = await loadAndVerifyUser(firestore, id, authToken, null);
  if (user === null) {
    id = null;
    authToken = null;
  }

  // Load the players.
  const players: {id: string, data: Player}[] = await loadPlayersAndIds(
    res, allPlayersRef(firestore, code).get());
  if (players === null) return;
  console.log("Players are " + JSON.stringify(players));

  // Load the other users.
  const playerUsers = new Map();
  for (const player of players) {
    if (player.id === id) continue;

    const playerUser: User = await loadUser(firestore, player.id, res);
    if (playerUser === null) return;
    playerUsers[player.id] = playerUser;
  }

  // Send back the game's state.
  res.set('application/json').send({
    name: game.name,
    state: game.state,
    created: game.created,
    end: game.end,
    players: players.map((player, _, __) => {
      if (player.id === id) {
        // This is the player who requested the information.
        // Provide detailed information.
        return {
          id: id,
          name: user.name,
          state: player.data.state,
          murderer: player.data.murderer,
          victim: player.data.victim,
          wasOutsmarted: player.data.wasOutsmarted,
          deaths: player.data.deaths.map((death, ___, ____) => {
            return {
              time: death.time,
              murderer: death.murderer,
              weapon: death.weapon,
              lastWords: death.lastWords,
            };
          }),
          kills: player.data.kills,
        };
      } else {
        // This is some other player.
        // Only provide superficial information.
        const playerUser: User = playerUsers[player.id];
        return {
          id: player.id,
          name: playerUser.name,
          state: player.data.state,
          deaths: player.data.deaths.map((death, ___, ____) => {
            return {
              time: death.time,
              weapon: death.weapon,
              lastWords: death.lastWords,
            };
          }),
        };
      }
    })
  });
}
