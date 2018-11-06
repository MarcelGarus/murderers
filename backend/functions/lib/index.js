"use strict";
/// The webhook entry point for the backend.
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const createGame = require("./create_game");
const joinGame = require("./join_game");
const admin = require("firebase-admin");
const util_1 = require("util");
util_1.log('Initializing app.');
const app = admin.initializeApp();
/// Creates a new game.
exports.create_game = functions.https.onRequest(createGame.handleRequest);
/// Joins a player to a game.
exports.join_game = functions.https.onRequest(joinGame.handleRequest);
/// Starts or resumes the game.
///
/// Needs:
/// * Firebase auth in header
/// * a game id
/// Returns:
/// 200: {}
// exports.start_game = functions.http.onRequest(startGame.handleRequest);
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
//# sourceMappingURL=index.js.map