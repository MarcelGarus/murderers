"use strict";
/// Starts an existing game.
///
/// Needs:
/// * [me]
/// * [authToken]
/// * [game]
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
const constants_1 = require("./constants");
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!utils_1.queryContains(req.query, [
            'me', 'authToken', 'game'
        ], res))
            return;
        const firestore = admin.app().firestore();
        const id = req.query.me;
        const authToken = req.query.authToken;
        const code = req.query.game;
        util_1.log(code + ': Starting the game.');
        // Load the game.
        const game = yield utils_1.loadGame(res, firestore, code);
        if (game === null)
            return;
        // Make sure the game didn't start yet.
        if (game.state !== models_1.GAME_NOT_STARTED_YET) {
            const errText = 'The game already started.';
            res.status(constants_1.CODE_ILLEGAL_STATE).send(errText);
            util_1.log(errText);
            return;
        }
        // Verify the creator.
        if (!utils_1.verifyCreator(game, id, res))
            return;
        const user = yield utils_1.loadAndVerifyUser(firestore, id, authToken, res);
        if (user === null)
            return;
        // Get all the players and make sure there are enough.
        const acceptedPlayersRef = utils_1.allPlayersRef(firestore, code)
            .where('state', '==', models_1.PLAYER_ALIVE);
        const players = yield utils_1.loadPlayersAndIds(res, acceptedPlayersRef.get());
        if (!players)
            return;
        if (players.length < constants_1.GAME_MINIMUM_PLAYERS) {
            const errText = 'There are only ' + players.length + ' players, but '
                + constants_1.GAME_MINIMUM_PLAYERS + ' are required to start the game.';
            res.status(constants_1.CODE_ILLEGAL_STATE).send(errText);
            util_1.log(errText);
            return;
        }
        // Shuffle all the players and change the game state.
        const batch = firestore.batch();
        shuffle_victims_1.shuffleVictims(players);
        players.forEach((player) => {
            batch.update(utils_1.playerRef(firestore, code, player.id), player.data);
        });
        batch.update(utils_1.gameRef(firestore, code), { state: models_1.GAME_RUNNING });
        yield batch.commit();
        // Send a response.
        res.send('Game started.');
        // Notify everyone that the game started.
        admin.messaging().send({
            notification: {
                title: 'The game just started',
                body: 'Get ready for an exciting time!',
            },
            android: {
                priority: 'normal',
                collapseKey: 'game_' + code,
                notification: { color: '#ff0000' },
            },
            condition: "'game_" + code + "' in topics",
        }).catch((error) => {
            util_1.log('Error while sending "game started" message: ' + error);
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=start_game.js.map