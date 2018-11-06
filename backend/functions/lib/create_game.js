"use strict";
/// Creates a new game.
///
/// Needs:
/// * Firebase auth in header
/// * a name
/// * ...
///
/// Returns:
/// 200: { code: 'abcd', game: { /* game configuration */ } }
/// 403: {}
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
const util_1 = require("util");
const utils_1 = require("./utils");
const GAME_CODE_LENGTH = 4;
/// Creates a new game code.
// TODO: make sure code doesn't already exist
// TODO: use analytics to log how many tries were needed
function createGameCode() {
    return __awaiter(this, void 0, void 0, function* () {
        const code = utils_1.generateRandomString('abcdefghiojklnopqrstuvwxyz0123456789', GAME_CODE_LENGTH);
        return code;
    });
}
/// Creates a new game.
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        util_1.log('App is ' + admin.app());
        util_1.log('Creating a game.');
        const game = {
            name: 'A sample game',
            isRunning: false,
            start: 0,
            end: 100,
            creatorId: 0,
        };
        const code = yield createGameCode();
        yield admin.app().firestore()
            .collection('games')
            .doc(code)
            .set(game);
        res.set('text/json').send({
            code: code,
            game: game,
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=create_game.js.map