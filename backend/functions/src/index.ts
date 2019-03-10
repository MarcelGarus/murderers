/// The webhook entry point for the back-end.

import * as functions from 'firebase-functions';
import * as acceptPlayer from './accept_player';
import * as createUser from './create_user';
import * as createGame from './create_game';
import * as getGame from './get_game';
import * as joinGame from './join_game';
import * as startGame from './start_game';
import * as killPlayer from './kill_player';
import * as die from './die';
import * as shuffleVictims from './shuffle_victims';
import * as admin from 'firebase-admin';
import { log } from 'util';

log('Initializing app.');
admin.initializeApp();

/// Creates a user.
exports.create_user = functions.https.onRequest(createUser.handleRequest);

/// Creates a new game.
exports.create_game = functions.https.onRequest(createGame.handleRequest);

/// Joins a player to a game.
exports.join_game = functions.https.onRequest(joinGame.handleRequest);

/// Accepts a player who wants to join the game.
exports.accept_player = functions.https.onRequest(acceptPlayer.handleRequest);

/// Gets the game state.
exports.get_game = functions.https.onRequest(getGame.handleRequest);

/// Starts the game.
exports.start_game = functions.https.onRequest(startGame.handleRequest);

/// Kills the caller's victim.
exports.kill_player = functions.https.onRequest(killPlayer.handleRequest);

/// The caller confirms the death.
exports.die = functions.https.onRequest(die.handleRequest);

/// Shuffles the victims.
exports.shuffle_victims = functions.https.onRequest(shuffleVictims.handleRequest);
