"use strict";
/// Creation of new games.
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
const GAME_CODE_LENGTH = 4;
admin.initializeApp();
const db = admin.firestore();
/// Returns a new random game code.
function createRandomCode() {
    return __awaiter(this, void 0, void 0, function* () {
        const chars = 'abcdefghiojklnopqrstuvwxyz0123456789';
        let code = '';
        while (code.length < GAME_CODE_LENGTH) {
            code += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return code;
    });
}
/// Creates a new game.
function createGame() {
    return __awaiter(this, void 0, void 0, function* () {
        const game = {
            code: yield createRandomCode(),
            isRunning: false,
            start: 0,
            end: 100,
        };
        const snapshot = yield db
            .collection('games')
            .doc(game.code)
            .set(game);
        return game;
    });
}
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        console.log('Creating a game inside its own file.');
        const game = yield createGame();
        res.set('text/json').send(game);
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=create_game.js.map