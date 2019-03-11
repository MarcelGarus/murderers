"use strict";
/// A player dies by confirming his/her death.
///
/// Needs:
/// * [me]
/// * [authToken]
/// * [game]
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
const constants_1 = require("./constants");
/// Offers webhook for dying.
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!utils_1.queryContains(req.query, [
            'me', 'authToken', 'game', 'weapon', 'lastWords'
        ], res))
            return;
        const firestore = admin.app().firestore();
        const authToken = req.query.authToken;
        const code = req.query.game;
        const id = req.query.me;
        const weapon = req.query.weapon;
        const lastWords = req.query.lastWords;
        util_1.log(code + ': Player ' + id + ' dies with honor.');
        // Verify the user.
        const user = yield utils_1.loadAndVerifyUser(firestore, id, authToken, res);
        if (user === null)
            return;
        // Verify that the victim is dying.
        const victim = yield utils_1.loadPlayer(res, firestore, code, id);
        if (victim === null)
            return;
        if (victim.state !== models_1.PLAYER_DYING || victim.murderer === null) {
            res.status(constants_1.CODE_ILLEGAL_STATE).send('You are not dying!');
            return;
        }
        // Load the murderer.
        const murderer = yield utils_1.loadPlayer(res, firestore, code, victim.murderer);
        if (murderer === null)
            return;
        // Load players who wait for a victim to be assigned to them.
        const newPlayersPromise = utils_1.allPlayersRef(firestore, code)
            .where('state', '==', models_1.PLAYER_ALIVE)
            .where('victim', '==', null)
            .get();
        const newPlayers = yield utils_1.loadPlayersAndIds(res, newPlayersPromise);
        if (newPlayers === null)
            return;
        // All players who want new victims are shuffled.
        shuffle_victims_1.shuffleVictims(newPlayers);
        if (newPlayers.length > 0) {
            murderer.victim = newPlayers[0].id;
            newPlayers[0].data.victim = victim.victim;
        }
        else {
            murderer.victim = victim.victim;
        }
        // Update waiting players.
        for (const player of newPlayers) {
            yield utils_1.playerRef(firestore, code, player.id).update(player.data);
        }
        // Update the murderer.
        yield utils_1.playerRef(firestore, code, victim.murderer).update({
            state: models_1.PLAYER_ALIVE,
            victim: murderer.victim,
            isOutsmarted: false,
            kills: murderer.kills + 1,
        });
        // Update the victim.
        yield utils_1.playerRef(firestore, code, id).update({
            state: models_1.PLAYER_DEAD,
            victim: null,
            isOutsmarted: false,
            death: {
                time: Date.now(),
                murderer: victim.murderer,
                weapon: weapon,
                lastWords: lastWords
            }
        });
        // Send response.
        res.send('You died.');
        // Send a notification to the murderer.
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