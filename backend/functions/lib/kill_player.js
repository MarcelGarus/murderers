"use strict";
/// Kills a player. The victim still needs to confirm its death.
///
/// Needs:
/// * user [id]
/// * [authToken]
/// * game [code]
///
/// Returns either:
/// 200: Kill request sent to victim.
/// 403: Access denied.
/// 404: Game not found.
/// 500: Corrupt data.
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
/// Offers webhook for killing the victim.
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
        util_1.log(code + ': Player ' + id + ' kills his/her victim.');
        // Load the user and verify Firebase Auth token.
        const user = yield utils_1.loadAndVerifyUser(firestore, id, authToken, res);
        if (user === null)
            return;
        // Load the murderer.
        const murderer = yield utils_1.loadPlayer(res, firestore, code, id);
        if (murderer === null)
            return;
        // Kill the victim.
        if (murderer.victim === null)
            return;
        yield utils_1.playerRef(firestore, code, murderer.victim).update({
            state: models_1.PLAYER_DYING,
            murderer: id,
        });
        // Load the victim.
        const victimUser = yield utils_1.loadUser(firestore, murderer.victim, res);
        // Send response.
        res.send('Kill request sent to victim.');
        // Send notification to the victim.
        admin.messaging().send({
            notification: {
                title: 'You are dying!',
                body: 'Did ' + user.name + ' just kill you?',
            },
            android: {
                priority: 'high',
                collapseKey: 'killed_' + code,
                notification: {
                    color: '#ff0000',
                },
            },
            token: victimUser.messagingToken,
        }).then((response) => {
            util_1.log('Successfully sent message. Message id: ' + response);
        }).catch((error) => {
            util_1.log('Error sending message: ' + error);
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=kill_player.js.map