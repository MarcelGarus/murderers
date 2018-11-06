"use strict";
/// Joins a player to a game.
///
/// Needs:
/// * a player name
///
/// Returns:
/// 200: { id: 'abcdefghiojklmonop', auth: 'dfsiidfsd' }
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
const utils_1 = require("./utils");
const util_1 = require("util");
const PLAYER_ID_LENGTH = 2;
const AUTH_TOKEN_LENGTH = 16;
/// Creates a new player id.
// TODO: make sure id doesn't already exist
// TODO: use analytics to log how many tries were needed
function createPlayerId() {
    return __awaiter(this, void 0, void 0, function* () {
        const id = utils_1.generateRandomString('abcdefghiojklnopqrstuvwxyz0123456789', PLAYER_ID_LENGTH);
        return id;
    });
}
/// Creates a new auth token.
function createAuthToken() {
    return utils_1.generateRandomString('abcdefghiojklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', AUTH_TOKEN_LENGTH);
}
/// Joins a player to a game.
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        console.log('Request query is ' + JSON.stringify(req.query));
        const db = admin.app().firestore();
        const code = req.query.code + '';
        const game = yield utils_1.loadGame(db, code);
        console.log('Joining the game ' + code + '.');
        if (util_1.isUndefined(game)) {
            console.log("Joining the game failed, because the game couldn't be loaded.");
            res.status(500).set('application/json').send('Joining the game failed.');
            return;
        }
        console.log('Game to join is ' + game);
        const player = {
            authToken: createAuthToken(),
            name: 'Marcel',
            victim: '',
            death: null
        };
        const id = yield createPlayerId();
        yield db
            .collection('games')
            .doc(code)
            .collection('players')
            .doc(id)
            .set(player);
        res.set('application/json').send(player);
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=join_game.js.map