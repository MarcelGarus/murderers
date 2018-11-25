/// Joins a player to a game.
///
/// Needs:
/// * a player name
///
/// Returns either:
/// 200: { id: 'abcdefghiojklmonop', authToken: 'dfsiidfsd' }
/// 404: Game not found.
/// 500: Game corrupt.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GameCode, Game, PlayerId, AuthToken, Player } from './models';
import { loadGame, generateRandomString } from './utils';
import { Message } from 'firebase-functions/lib/providers/pubsub';

const PLAYER_ID_CHARS = 'abcdefghiojklnopqrstuvwxyz0123456789';
const PLAYER_ID_LENGTH = 2;
const AUTH_TOKEN_CHARS = 'abcdefghiojklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
const AUTH_TOKEN_LENGTH = 16;

/// Creates a new player id.
// TODO: make sure id doesn't already exist
// TODO: use analytics to log how many tries were needed
async function createPlayerId(): Promise<PlayerId> {
  const id: PlayerId = generateRandomString(PLAYER_ID_CHARS, PLAYER_ID_LENGTH);
  return id;
}

/// Creates a new auth token.
function createAuthToken(): AuthToken {
  return generateRandomString(AUTH_TOKEN_CHARS, AUTH_TOKEN_LENGTH);
}

/// Joins a player to a game.
export async function handleRequest(req: functions.Request, res: functions.Response) {
  console.log('Request query is ' + JSON.stringify(req.query));

  // Get a reference to the database and the game code.
  const db = admin.app().firestore();
  const code: GameCode = req.query.code + '';
  const name: string = req.query.name + '';
  const messagingToken: string = req.query.messagingToken + '';
  let game: Game;

  console.log(name + ' joins the game ' + code + '.');

  // Try to load the game.
  try {
    game = await loadGame(db, code);
  } catch (error) {
    console.log("Joining the game failed, because the game couldn't be loaded. Error is:");
    console.log(error);

    if (true) { // TODO: check error message
      res.status(404).send('Game not found.');
    } else {
      res.status(500).send('Game corrupt.');
    }
  }

  // Game loaded successfully. Now join it.
  console.log('Game to join is ' + game);

  const player: Player = {
    authToken: createAuthToken(),
    messagingToken: messagingToken,
    name: name,
    victim: null,
    death: null
  };

  const id: PlayerId = await createPlayerId();

  await db
    .collection('games')
    .doc(code)
    .collection('players')
    .doc(id)
    .set(player);

  // Send back the player id and the authToken.
  res.set('application/json').send({
    id: id,
    authToken: player.authToken,
  });

  // TODO: Also send a notification to _all_ members of the game that opted in for notifications about new players.
  var message: admin.messaging.Message = {
    notification: {
      title: 'Someone just joined the game ' + code,
      body: 'Say hi by killing ' + id + '!',
    },
    android: {
      priority: 'normal',
      collapseKey: 'someone_joins_' + code,
      notification: {
        color: '#ff0000',
      },
    },
    token: 'emd1IxAjbQg:APA91bF7MNO65rvy3Pg_XGEkJPHNdCSLpmahmreQYYRVEAzsIXaeg2XQNdRUHphERXzAX8WTRXnEEdisiMNsWoTQF-ee5HHDN8Gn1TIfF0MVxDbWso21JxDJt5-9-QtVUc2Jfe6EJYq7'
  };

  admin.messaging().send(message)
    .then((response) => {
      // Response is a message ID string.
      console.log('Successfully sent message:', response);
    })
    .catch((error) => {
      console.log('Error sending message:', error);
    });
}
