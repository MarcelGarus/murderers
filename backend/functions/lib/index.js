"use strict";
/// The webhook entry point for the back-end.
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const createUser = require("./create_user");
const createGame = require("./create_game");
const getGame = require("./get_game");
const joinGame = require("./join_game");
const startGame = require("./start_game");
const killPlayer = require("./kill_player");
const die = require("./die");
const shuffleVictims = require("./shuffle_victims");
const admin = require("firebase-admin");
const util_1 = require("util");
util_1.log('Initializing app.');
admin.initializeApp();
/// Creates a user.
exports.create_user = functions.https.onRequest(createUser.handleRequest);
/// Creates a new game.
exports.create_game = functions.https.onRequest(createGame.handleRequest);
/// Joins a player to a game.
exports.join_game = functions.https.onRequest(joinGame.handleRequest);
/// Gets the game state.
exports.get_game = functions.https.onRequest(getGame.handleRequest);
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
/// Kills the caller's victim.
exports.kill_player = functions.https.onRequest(killPlayer.handleRequest);
/// The caller confirms the death.
exports.die = functions.https.onRequest(die.handleRequest);
/// Shuffles the victims.
exports.shuffle_victims = functions.https.onRequest(shuffleVictims.handleRequest);
//# sourceMappingURL=index.js.map