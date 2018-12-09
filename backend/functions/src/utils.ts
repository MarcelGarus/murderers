
import { Game, isGame } from './models';

// Errors.
export const NO_ACCESS: string = 'Access denied.';
export const GAME_NOT_FOUND: string = 'Game not found.';
export const GAME_CORRUPT: string = 'Game corrupt.';

// Success return codes.
export const GAME_STARTED: string = 'Game started.';

/// Generates a random string from the given base chars with the given length.
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

/// Loads a game with the given code.
export async function loadGame(firestore: FirebaseFirestore.Firestore, code: string): Promise<Game> {
  const snapshot = await firestore
    .collection('games')
    .doc(code)
    .get();

  if (!snapshot.exists) {
    throw new Error(GAME_NOT_FOUND);
  }

  const data = snapshot.data();

  if (!isGame(data)) {
    throw new Error(GAME_CORRUPT);
  }

  // @ts-ignore (casting data to Game)
  return data;
}
