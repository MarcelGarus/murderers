/// The webhook entry point for the backend.

import * as functions from 'firebase-functions';
import * as createGame from './create_game';
import * as joinGame from './join_game';
import * as startGame from './start_game';
import * as admin from 'firebase-admin';
import { log } from 'util';

log('Initializing app.');
const app = admin.initializeApp();

/// Creates a new game.
exports.create_game = functions.https.onRequest(createGame.handleRequest);

/// Joins a player to a game.
exports.join_game = functions.https.onRequest(joinGame.handleRequest);

/// Starts or resumes the game.
exports.start_game = functions.https.onRequest(startGame.handleRequest);

/// Pauses or stops the game.
///
/// Needs:
/// * Firebase auth in header
/// * a game id
/// Returns:
/// 200: {}
// exports.stop_game = functions.https.onRequest(stopGame.handleRequest);

/// Killer kills victim.
/// Needs:
/// * a game id
/// * a player id & auth
// exports.kill = functions.https.onRequest(kill.handleRequest);

/// Victim confirms its death.
/// Needs:
/// * a game id
/// * a player id & auth
/// * last words
/// * murder weapon
// exports.confirm_death = functions.https.onRequest(confirmDeath.handleRequest);
