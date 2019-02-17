/// Utilities.

import * as functions from 'firebase-functions';
import { Game, isGame, GameCode, UserId, Player, isPlayer, FirebaseAuthToken, User, isUser } from './models';
import { log } from 'util';

// Error codes.
export const CODE_BAD_REQUEST: number = 400;
export const CODE_USER_NOT_FOUND: number = 404;
export const CODE_USER_CORRUPT: number = 500;
export const CODE_AUTHENTIFICATION_FAILED: number = 403;
export const CODE_NO_PRIVILEGES: number = 403;
export const CODE_GAME_NOT_FOUND: number = 404;
export const CODE_GAME_CORRUPT: number = 500;
export const CODE_PLAYER_NOT_FOUND: number = 404;
export const CODE_PLAYER_CORRUPT: number = 500;

// Error texts.
export const TEXT_USER_NOT_FOUND: string = 'User not found.';
export const TEXT_USER_CORRUPT: string = 'User corrupt.';
export const TEXT_AUTHENTIFICATION_FAILED: string = 'Authentification failed.';
export const TEXT_NO_PRIVILEGES: string = 'No privileges.';
export const TEXT_GAME_NOT_FOUND: string = 'Game not found.';
export const TEXT_GAME_CORRUPT: string = 'Game corrupt.';
export const TEXT_PLAYER_NOT_FOUND: string = 'Player not found.';
export const TEXT_PLAYER_CORRUPT: string = 'Player corrupt.';

/// Generates a length-long random string using the provided chars.
export function generateRandomString(chars: string, length: number): string {
  let s: string = '';

  while (s.length < length) {
    s += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return s;
}

/// Shuffles an array in place using the Fisher-Yates algorithm.
export function shuffle(array) {
  let m = array.length, t, i;

  while (m) {
    i = Math.floor(Math.random() * m--);
    t = array[m];
    array[m] = array[i];
    array[i] = t;
  }

  return array;
}

/// Checks if the query contains all the required parameters.
/// If not, sends a response (if res is not null) and returns false.
export function queryContains(
  query,
  parameters: string[],
  res?: functions.Response
): boolean {
  for (const arg of parameters) {
    if (query[arg] === undefined || typeof query[arg] !== 'string') {
      if (res !== null) {
        res.status(CODE_BAD_REQUEST)
          .send('Bad request. ' + arg + ' parameter missing.');
      }
      return false;
    }
  }
  return true;
}

/// Returns a Firestore reference to the user with the id.
export function userRef(
  firestore: FirebaseFirestore.Firestore,
  id: UserId
): FirebaseFirestore.DocumentReference {
  return firestore.collection('users').doc(id);
}

/// Loads a user.
export async function loadUser(
  firestore: FirebaseFirestore.Firestore,
  id: UserId,
  res: functions.Response
): Promise<User> {
  if (id === null || id === undefined) return null;

  const snapshot = await userRef(firestore, id).get();

  if (!snapshot.exists && res !== null) {
    res.status(CODE_USER_NOT_FOUND).send(TEXT_USER_NOT_FOUND);
    return null;
  }

  const data = snapshot.data();

  if (!isUser(data)) {
    if (res !== null) {
      res.status(CODE_USER_CORRUPT).send(TEXT_USER_CORRUPT);
    }
    log('Corrupt user: ' + JSON.stringify(data));
    return null;
  }

  return data as User;
}

/// Loads and verifies the user with the id.
export async function loadAndVerifyUser(
  firestore: FirebaseFirestore.Firestore,
  id: UserId,
  providedAuthToken: FirebaseAuthToken,
  res: functions.Response
): Promise<User> {
  const user: User = await loadUser(firestore, id, res);
  if (user === null) return null;

  if (user.authToken !== providedAuthToken) {
    if (res !== null) {
      res.status(CODE_AUTHENTIFICATION_FAILED)
      .send(TEXT_AUTHENTIFICATION_FAILED);
    }
    return null;
  }

  return user;
}

/// Verifies that the user is the creator of the game. 
export function verifyCreator(
  game: Game,
  userId: UserId,
  res: functions.Response
): boolean {
  if (game.creator === userId) {
    return true;
  }
  res.status(CODE_NO_PRIVILEGES).send(TEXT_NO_PRIVILEGES);
  return false;
}

/// Returns a Firestore reference to the game with the code.
export function gameRef(
  firestore: FirebaseFirestore.Firestore,
  code: GameCode
): FirebaseFirestore.DocumentReference {
  return firestore.collection('games').doc(code);
}

/// Loads a game with the code.
/// If errors occur, they are handled and the function just returns null.
export async function loadGame(
  res: functions.Response,
  firestore: FirebaseFirestore.Firestore,
  code: GameCode
): Promise<Game> {
  const snapshot = await gameRef(firestore, code).get();

  if (!snapshot.exists) {
    res.status(CODE_GAME_NOT_FOUND).send(TEXT_GAME_NOT_FOUND);
    return null;
  }

  const data = snapshot.data();

  if (!isGame(data)) {
    res.status(CODE_GAME_CORRUPT).send(TEXT_GAME_CORRUPT);
    log('Corrupt game: ' + JSON.stringify(data));
    return null;
  }

  return data as Game;
}

/// Returns a Firestore reference to the collection of players of the game
/// with the code.
export function allPlayersRef(
  firestore: FirebaseFirestore.Firestore,
  code: GameCode
): FirebaseFirestore.CollectionReference {
  return gameRef(firestore, code).collection('players');
}

/// Returns a Firestore reference to the player with the id.
export function playerRef(
  firestore: FirebaseFirestore.Firestore,
  code: GameCode,
  id: UserId
): FirebaseFirestore.DocumentReference {
  return allPlayersRef(firestore, code).doc(id);
}

/// Loads a player with the id of the game with the code.
/// If errors occur, they are handled and the function just returns null.
export async function loadPlayer(
  res: functions.Response,
  firestore: FirebaseFirestore.Firestore,
  code: GameCode,
  id: UserId
): Promise<Player> {
  const snapshot = await playerRef(firestore, code, id).get();

  if (!snapshot.exists) {
    res.status(CODE_PLAYER_CORRUPT).send(TEXT_PLAYER_NOT_FOUND);
    return null;
  }

  const data = snapshot.data();

  if (!isPlayer(data)) {
    res.status(CODE_PLAYER_CORRUPT).send(TEXT_PLAYER_CORRUPT);
    log('Corrupt player: ' + JSON.stringify(data));
    return null;
  }

  return data as Player;
}


/// Loads all player of a game with their ids.
/// If errors occur, they are handled and the function just returns null.
export async function loadPlayersAndIds(
  res: functions.Response,
  snapshotPromise: Promise<FirebaseFirestore.QuerySnapshot>
): Promise<Array<{id: string, data: Player}>> {
  const players: {id, data: Player}[] = [];
  const snapshot = await snapshotPromise;
  let success = true;

  snapshot.forEach(doc => {
    const data = doc.data();

    if (isPlayer(data)) {
      players.push({
        id: doc.id,
        data: data as Player
      });
    } else {
      res.status(CODE_PLAYER_CORRUPT).send(TEXT_PLAYER_CORRUPT);
      log('Corrupt player: ' + JSON.stringify(data));
      success = false;
    }
  });

  return success ? players : null;
}
