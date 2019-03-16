"use strict";
/// Joins a player to a game. The game creator will still need to approve of the
/// new player for the joining to have any effect.
///
/// Needs:
/// * [me]
/// * [authToken]
/// * [game]
///
/// Returns either:
/// 200: Joined.
/// 400: Bad request.
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
const util_1 = require("util");
const constants_1 = require("./constants");
/// Joins a player to a game.
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
        util_1.log(code + ': ' + id + ' joins.');
        // Load and verify the user.
        const user = yield utils_1.loadAndVerifyUser(firestore, id, authToken, res);
        if (user === null)
            return;
        // Load the game.
        const game = yield utils_1.loadGame(res, firestore, code);
        if (game === null)
            return;
        // Make sure user didn't already join.
        const existingPlayer = yield utils_1.playerRef(firestore, code, id).get();
        if (existingPlayer.exists) {
            const errText = 'You already joined this game.';
            res.status(constants_1.CODE_ILLEGAL_STATE).send(errText);
            return;
        }
        // Create the player.
        const isCreator = (id === game.creator);
        const player = {
            state: isCreator ? models_1.PLAYER_ALIVE : models_1.PLAYER_JOINING,
            kills: 0,
            murderer: null,
            victim: null,
            wantsNewVictim: isCreator,
            death: null
        };
        yield utils_1.playerRef(firestore, code, id).set(player);
        // Send response.
        res.set('application/json').send('Joined.');
        // Get the creator.
        const creator = yield utils_1.loadUser(firestore, game.creator, res);
        if (creator === null) {
            util_1.log("Creator couldn't be found and notified.");
            return;
        }
        // Send a notification to the creator.
        admin.messaging().send({
            notification: {
                title: user.name + ' wants to join the game',
                body: 'Tap to go to the admin panel.',
            },
            android: {
                priority: 'high',
                collapseKey: 'game_' + code + '_admin',
                notification: {
                    color: '#ff0000',
                },
            },
            token: creator.messagingToken
        }).catch((error) => {
            util_1.log('Error sending message to creator: ' + error);
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=join_game.js.map