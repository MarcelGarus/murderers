"use strict";
/// The main entry point for the backend.
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const createGame = require("./create_game");
/// Gets a user.
/*async function getUser(id: string) {
  const snapshot = await db.collection('users')
    .where('id', '==', id)
    .limit(1)
    .get();
}*/
// Creates game.
exports.create_game = functions.https.onRequest(createGame.handleRequest);
//# sourceMappingURL=index.js.map