/// Accepts one or multiple newly joined players into a game.
///
/// Needs:
/// * creator [id]
/// * [authToken]
/// * game [code]
/// * a "_"-separated list of ids of players that should be [accept]ed
///
/// Returns either:
/// 200: Joined.
/// 400: Bad request.
/// 403: Access denied.
/// 404: Game not found.
/// 500: Game corrupt.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, Game, UserId, FirebaseAuthToken, User, PLAYER_ALIVE, Player, PLAYER_JOINING } from './models';
import { loadGame, playerRef, queryContains, loadAndVerifyUser, loadUser, verifyCreator, loadPlayersAndIds, allPlayersRef, loadPlayer } from './utils';
import { log } from 'util';
import { CODE_ILLEGAL_STATE, CODE_BAD_REQUEST } from './constants';

export async function handleRequest(req: functions.Request, res: functions.Response) {
  if (!queryContains(req.query, [
    'id', 'authToken', 'code', 'accept'
  ], res)) return;

  const firestore = admin.app().firestore();
  const id: UserId = req.query.id;
  const authToken: FirebaseAuthToken = req.query.authToken;
  const code: GameCode = req.query.code;
  const accept: string[] = req.query.accept.split('_').filter(s => s != "");

  log(code + ': Accepting all these players: ' + accept);

  // Make sure there are players to accept.
  if (accept.length === 0) {
    res.status(CODE_BAD_REQUEST).send('No players to accept given.');
    return;
  }

  // Load the game.
  const game: Game = await loadGame(res, firestore, code);
  if (game === null) return;

  // Verify the creator.
  if (!verifyCreator(game, id, res)) return;
  const creator: User = await loadAndVerifyUser(firestore, id, authToken, res);
  if (creator === null) return;

  // Make sure all those users are actually players in the game and they weren't
  // accepted yet.
  const usersToAccept: User[] = [];
  for (const acceptId in accept) {
    const player: Player = await loadPlayer(res, firestore, code, acceptId);
    if (player === null) return;
    if (player.state !== PLAYER_JOINING) {
      res.status(CODE_ILLEGAL_STATE)
        .send('Player ' + acceptId + ' was already accepted.');
      return;
    }
  }

  // Accept all the players by changing their state.
  const batch = firestore.batch();
  for (const acceptId in accept) {
    batch.update(playerRef(firestore, code, acceptId), {
      state: PLAYER_ALIVE,
      wantsNewVictim: true,
    });
  }
  await batch.commit();
  
  // Send a response.
  res.send('Players accepted.');

  // Send notifications.
  for (const acceptId in accept) {
    const acceptUser: User = await loadUser(firestore, acceptId, null);
    if (acceptUser === null) {
      log('Accepted user ' + acceptId + ' not found.');
      continue;
    }

    // Notify all the accepted players that they got accepted.
    admin.messaging().send({
      notification: {
        title: 'You got accepted',
        body: 'You just joined the game "' + game.name + '".',
      },
      android: {
        priority: 'high',
        collapseKey: 'game_' + code,
        notification: { color: '#ff0000' },
      },
      token: acceptUser.messagingToken
    }).catch((error) => {
      log('Error while sending "you got accepted" message: ' + error);
    });

    // Notify all other players that they got accepted.
    // TODO: only notify the other players
    admin.messaging().send({
      notification: {
        title: acceptUser.name + ' just joined the game',
        body: '',
      },
      android: {
        priority: 'normal',
        collapseKey: 'game_' + code,
        notification: { color: '#ff0000' },
      },
      token: "'game_" + code + "' in topics && 'player_joined' in topics"
    }).catch((error) => {
      log('Error while sending "a new player joined" message: ' + error);
    });
  }
}
