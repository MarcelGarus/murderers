
import { Game, isGame } from './models';

/// Generates a random string from the given base chars with the given length.
export function generateRandomString(chars: string, length: number): string {
  let s: string = '';

  while (s.length < length) {
    s += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return s;
}

/// Loads a game with the given code.
export async function loadGame(firestore: FirebaseFirestore.Firestore, code: string): Promise<Game> {
  const snapshot = await firestore
    .collection('games')
    .doc(code)
    .get();

  if (!snapshot.exists) {
    console.log('Game ' + code + ' does not exist.');
    return undefined;
  }

  const data = snapshot.data();

  if (!isGame(data)) {
    console.log('Snapshot data ' + JSON.stringify(data) + ' is not a game.');
    return undefined;
  }

  // @ts-ignore
  const game: Game = data;

  return game;
}
