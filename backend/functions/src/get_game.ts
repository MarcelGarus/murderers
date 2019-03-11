/// Returns a game's state.
///
/// Needs:
/// * [game]
/// Optional:
/// * [me]
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
import { Death, GameCode, Game, Player, UserId, FirebaseAuthToken, User } from './models';
import { loadGame, loadPlayersAndIds, allPlayersRef, queryContains, loadAndVerifyUser, loadUser } from './utils';

/// Returns a game's state.
// TODO: handle no id and code given
export async function handleRequest(req: functions.Request, res: functions.Response) {
  if (!queryContains(req.query, [
    'game'
  ], res)) return;

  const firestore = admin.app().firestore();
  let id: UserId = req.query.me;
  let authToken: FirebaseAuthToken = req.query.authToken;
  const code: GameCode = req.query.game + '';

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
    creator: game.creator,
    end: game.end,
    players: players.map((playerAndId, _, __) => {
      const playerId: UserId = playerAndId.id;
      const player: Player = playerAndId.data;
      const death: Death = player.death;
      const isMe: boolean = (playerId === id);

      if (isMe) {
        return {
          id: id,
          name: user.name,
          state: player.state,
          murderer: player.murderer,
          victim: player.victim,
          kills: player.kills,
          wantsNewVictim: player.wantsNewVictim,
          death: death === null ? null : {
            time: death.time,
            murderer: death.murderer,
            weapon: death.weapon,
            lastWords: death.lastWords
          }
        };
      } else {
        return {
          id: playerId,
          name: playerUsers[playerId].name,
          state: player.state,
          kills: player.kills,
          death: death === null ? null : {
            time: death.time,
            weapon: death.weapon,
            lastWords: death.lastWords
          }
        };
      }
    })
  });
}
