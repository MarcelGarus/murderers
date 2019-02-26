"use strict";
/// A player dies by confirming his/her death.
///
/// Needs:
/// * user [id]
/// * [authToken]
/// * game [code]
/// * [weapon]
/// * [lastWords]
///
/// Returns either:
/// 200: You died.
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
const shuffle_victims_1 = require("./shuffle_victims");
const util_1 = require("util");
/// Offers webhook for dying.
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!utils_1.queryContains(req.query, [
            'id', 'authToken', 'code', 'weapon', 'lastWords'
        ], res))
            return;
        const firestore = admin.app().firestore();
        const authToken = req.query.authToken;
        const code = req.query.code;
        const id = req.query.id;
        const weapon = req.query.weapon;
        const lastWords = req.query.lastWords;
        util_1.log(code + ': Player ' + id + ' dies with honor.');
        // Verify the user.
        const user = yield utils_1.loadAndVerifyUser(firestore, id, authToken, res);
        if (user === null)
            return;
        // Verify the victim's dying.
        const victim = yield utils_1.loadPlayer(res, firestore, code, id);
        if (victim === null)
            return;
        if (victim.state !== models_1.PLAYER_DYING || victim.murderer === null)
            return;
        // Load the murderer.
        const murderer = yield utils_1.loadPlayer(res, firestore, code, victim.murderer);
        if (murderer === null)
            return;
        // Load all waiting players.
        const snapshotPromise = utils_1.allPlayersRef(firestore, code)
            .where('state', '==', models_1.PLAYER_WAITING)
            .get();
        const waiting = yield utils_1.loadPlayersAndIds(res, snapshotPromise);
        if (waiting === null)
            return;
        // All players that are waiting as well as the murderer get new victims.
        shuffle_victims_1.shuffleVictims(waiting);
        if (waiting.length > 0) {
            murderer.victim = waiting[0].id;
            waiting[0].data.victim = victim.victim;
        }
        else {
            murderer.victim = victim.victim;
        }
        // Update waiting players.
        for (const player of waiting) {
            yield utils_1.playerRef(firestore, code, player.id).update(player.data);
        }
        // Update the murderer.
        yield utils_1.playerRef(firestore, code, victim.murderer).update({
            state: models_1.PLAYER_ALIVE,
            victim: murderer.victim,
            wasOutsmarted: false,
            kills: murderer.kills + 1,
        });
        // Update the victim.
        yield utils_1.playerRef(firestore, code, id).update({
            state: models_1.PLAYER_DEAD,
            victim: null,
            wasOutsmarted: false,
            deaths: {
                time: Date.now(),
                murderer: victim.murderer,
                weapon: weapon,
                lastWords: lastWords
            }
        });
        // Send response.
        res.send('You died.');
        // Send a notification to _all_ subscribed users.
        admin.messaging().send({
            notification: {
                title: user.name + ' just died!',
                body: 'Killed with ' + weapon + '. Last words: "' + lastWords + '"',
            },
            android: {
                priority: 'normal',
                collapseKey: 'player_killed_' + code,
                notification: {
                    color: '#ff0000',
                },
            },
            condition: "'game_" + code + "' in topics && 'deaths' in topics",
        }).then((response) => {
            util_1.log('Successfully sent message. Message id: ' + response);
        }).catch((error) => {
            util_1.log('Error sending message: ' + error);
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=die.js.map