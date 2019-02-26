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
import { Death, GameCode, Game, Player, UserId, FirebaseAuthToken, User } from './models';
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
    creator: game.creator,
    end: game.end,
    players: players.map((playerAndId, _, __) => {
      const playerId: UserId = playerAndId.id;
      const player: Player = playerAndId.data;
      const death: Death = player.death;
      const isMe: boolean = (playerId === id);

      return {
        id: isMe ? id : playerId,
        name: isMe ? user.name : playerUsers[playerId].name,
        state: player.state,
        murderer: isMe ? player.murderer : null,
        victim: isMe ? player.victim : null,
        wasOutsmarted: isMe ? player.wasOutsmarted : null,
        death: death === null ? null : {
          time: death.time,
          murderer: isMe ? death.murderer : null,
          weapon: death.weapon,
          lastWords: death.lastWords,
        },
        kills: player.kills
      };
    })
  });
}
