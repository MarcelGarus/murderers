"use strict";
/// Joins a player to a game.
///
/// Needs:
/// * user [id]
/// * [authToken]
/// * game [code]
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
/// Joins a player to a game.
// TODO: Prevent player from joining twice.
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
        util_1.log(code + ': ' + id + ' joins.');
        // Load and verify the user.
        const user = yield utils_1.loadAndVerifyUser(firestore, id, authToken, res);
        if (user === null)
            return;
        // Load the game.
        const game = yield utils_1.loadGame(res, firestore, code);
        if (game === null)
            return;
        // Create the player.
        const player = {
            state: models_1.PLAYER_WAITING,
            murderer: null,
            victim: null,
            wasOutsmarted: false,
            death: null,
            kills: 0
        };
        yield utils_1.playerRef(firestore, code, id).set(player);
        // Send back the id.
        res.set('application/json').send('Joined.');
        // TODO: Also send a notification to _all_ members of the game that opted in for notifications about new players.
        admin.messaging().send({
            notification: {
                title: 'Someone just joined the game ' + code,
                body: 'Say hi by killing ' + id + '!',
            },
            android: {
                priority: 'normal',
                collapseKey: 'someone_joins_' + code,
                notification: {
                    color: '#ff0000',
                },
            },
            token: 'emd1IxAjbQg:APA91bF7MNO65rvy3Pg_XGEkJPHNdCSLpmahmreQYYRVEAzsIXaeg2XQNdRUHphERXzAX8WTRXnEEdisiMNsWoTQF-ee5HHDN8Gn1TIfF0MVxDbWso21JxDJt5-9-QtVUc2Jfe6EJYq7'
        }).then((response) => {
            util_1.log('Successfully sent message. Message id: ' + response);
        }).catch((error) => {
            util_1.log('Error sending message: ' + error);
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=join_game.js.map