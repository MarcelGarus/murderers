"use strict";
/// Creates a new game.
///
/// Needs:
/// * user [id]
/// * [authToken]
/// * game [name]
/// * (preliminary) [start] time
/// * (preliminary) [end] time
///
/// Returns either:
/// 200: { code: 'abcd' }
/// 400: Bad request.
/// 403: Access denied.
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
const models_1 = require("./models");
const utils_1 = require("./utils");
const constants_1 = require("./constants");
/// Creates a new game code.
function createGameCode(firestore) {
    return __awaiter(this, void 0, void 0, function* () {
        let code = '';
        let tries = 0;
        while (true) {
            code = utils_1.generateRandomString(constants_1.GAME_CODE_CHARS, constants_1.GAME_CODE_LENGTH);
            tries++;
            const snapshot = yield utils_1.gameRef(firestore, code).get();
            if (!snapshot.exists)
                break;
        }
        util_1.log(code + ': It took ' + tries + ' tries to create this game code.');
        return code;
    });
}
/// Offers webhook for creating a new game.
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!utils_1.queryContains(req.query, [
            'id', 'authToken', 'name', 'start', 'end'
        ], res))
            return;
        const firestore = admin.app().firestore();
        const id = req.query.id;
        const authToken = req.query.authToken;
        const name = req.query.name;
        const start = parseInt(req.query.number);
        const end = parseInt(req.query.end);
        util_1.log(id + 'creates a game named ' + name + '.');
        // Load and verify the user.
        const user = yield utils_1.loadAndVerifyUser(firestore, id, authToken, res);
        if (user === null)
            return;
        // Create the game.
        // TODO: sanitize name, make sure start and end dates are valid
        const game = {
            name: name,
            state: models_1.GAME_NOT_STARTED_YET,
            creator: id,
            created: Date.now(),
            start: start,
            end: end,
        };
        const code = yield createGameCode(firestore);
        yield utils_1.gameRef(firestore, code).set(game);
        util_1.log(code + ': Game created.');
        // Send back the code.
        res.set('application/json').send({
            code: code,
            name: game.name,
            created: game.created,
            start: game.start,
            end: game.end
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=create_game.js.map