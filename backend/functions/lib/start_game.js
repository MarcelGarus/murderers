"use strict";
/// Starts an existing game.
///
/// Needs:
/// * user [id]
/// * [authToken]
/// * game [code]
///
/// Returns either:
/// 200: Game started.
/// 403: Access denied.
/// 404: Game not found.
/// 500: Game corrupt.
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const admin = require("firebase-admin");
const models_1 = require("./models");
const utils_1 = require("./utils");
const shuffle_victims_1 = require("./shuffle_victims");
const util_1 = require("util");
/// Starts an existing game.
// TODO: make sure not already started
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!utils_1.queryContains(req.query, [
            'id', 'authToken', 'code'
        ], res))
            return;
        const firestore = admin.app().firestore();
        const id = req.query.id;
        const authToken = req.query.authToken;
        const code = req.query.code;
        util_1.log(code + ': Starting the game.');
        // Load the game.
        const game = yield utils_1.loadGame(res, firestore, code);
        if (game === null)
            return;
        // Verify the creator.
        if (!utils_1.verifyCreator(game, id, res))
            return;
        const user = yield utils_1.loadAndVerifyUser(firestore, id, authToken, res);
        if (user === null)
            return;
        // First, shuffle all the players.
        const players = yield utils_1.loadPlayersAndIds(res, utils_1.allPlayersRef(firestore, code).get());
        if (!players)
            return;
        shuffle_victims_1.shuffleVictims(players);
        players.forEach((player) => __awaiter(this, void 0, void 0, function* () {
            yield utils_1.playerRef(firestore, code, player.id).update(player.data);
        }));
        // Then, start the game.
        yield utils_1.gameRef(firestore, code).update({
            state: models_1.GAME_RUNNING
        });
        // Send a response.
        res.send('Game started.');
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=start_game.js.map