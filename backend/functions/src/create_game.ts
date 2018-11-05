/// Creation of new games.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { Game } from './models';

const GAME_CODE_LENGTH = 4;

admin.initializeApp();
const db = admin.firestore();

/// Returns a new random game code.
async function createRandomCode(): Promise<string> {
  const chars: string = 'abcdefghiojklnopqrstuvwxyz0123456789';
  let code: string = '';

  while (code.length < GAME_CODE_LENGTH) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

/// Creates a new game.
async function createGame(): Promise<Game> {
  const game: Game = {
    code: await createRandomCode(),
    isRunning: false,
    start: 0,
    end: 100,
  };

  const snapshot = await db
    .collection('games')
    .doc(game.code)
    .set(game);

  return game;
}

export async function handleRequest(req: functions.Request, res: functions.Response) {
  console.log('Creating a game inside its own file.');

  const game: Game = await createGame();
  res.set('text/json').send(game);
}
