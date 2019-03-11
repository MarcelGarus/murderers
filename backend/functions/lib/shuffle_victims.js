"use strict";
/// Shuffle all the players of a game.
///
/// Needs:
/// * [me]
/// * [authToken]
/// * game [code]
/// * whether to shuffle [onlyOutsmartedPlayers]
///
/// Returns either:
/// 200: Players shuffled.
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
/// Shuffles the given players' as victims locally and in-place.
function shuffleVictims(players) {
    // Actually shuffle the players.
    util_1.log('Shuffling ' + players.length + ' players.');
    utils_1.shuffle(players);
    // Update the players' victims locally.
    players.forEach((player, index) => {
        player.data.victim = players[(index > 0) ? (index - 1) : (players.length - 1)].id;
        player.data.state = models_1.PLAYER_ALIVE;
        util_1.log('Player ' + player.id + ' now has victim ' + player.data.victim + '.');
    });
}
exports.shuffleVictims = shuffleVictims;
/// Offers webhook for shuffling victims.
// TODO: offer option to not shuffle dead players
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!utils_1.queryContains(req.query, [
            'id', 'authToken', 'code', 'onlyOutsmarted'
        ], res))
            return;
        const firestore = admin.app().firestore();
        const id = req.query.me;
        const authToken = req.query.authToken;
        const code = req.query.code;
        const onlyOutsmartedPlayers = (req.query.onlyOutsmartedPlayers === 'true');
        util_1.log(code + ': Shuffling players. Only outsmarted ones? ' + onlyOutsmartedPlayers);
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
        // Get all the players that should be shuffled.
        let playersRef = utils_1.allPlayersRef(firestore, code);
        /*if (onlyAlivePlayers) {
          playersRef = playersRef.where('state', '==')
        }*/
        if (onlyOutsmartedPlayers) {
            playersRef = playersRef.where('wasOutsmarted', '==', true);
        }
        const players = yield utils_1.loadPlayersAndIds(res, playersRef.get());
        if (players === null)
            return;
        // Shuffle players.
        shuffleVictims(players);
        players.forEach((player) => __awaiter(this, void 0, void 0, function* () {
            yield utils_1.playerRef(firestore, code, player.id).update(player.data);
        }));
        // Send response.
        res.send('Players shuffled.');
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=shuffle_victims.js.map