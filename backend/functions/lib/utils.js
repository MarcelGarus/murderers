"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const models_1 = require("./models");
// Errors.
exports.NO_ACCESS = 'Access denied.';
exports.GAME_NOT_FOUND = 'Game not found.';
exports.GAME_CORRUPT = 'Game corrupt.';
// Success return codes.
exports.GAME_STARTED = 'Game started.';
/// Generates a random string from the given base chars with the given length.
function generateRandomString(chars, length) {
    let s = '';
    while (s.length < length) {
        s += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return s;
}
exports.generateRandomString = generateRandomString;
/// Shuffles an array in place using the Fisher-Yates algorithm.
function shuffle(array) {
    let m = array.length, t, i;
    while (m) {
        i = Math.floor(Math.random() * m--);
        t = array[m];
        array[m] = array[i];
        array[i] = t;
    }
    return array;
}
exports.shuffle = shuffle;
/// Loads a game with the given code.
function loadGame(firestore, code) {
    return __awaiter(this, void 0, void 0, function* () {
        const snapshot = yield firestore
            .collection('games')
            .doc(code)
            .get();
        if (!snapshot.exists) {
            throw new Error(exports.GAME_NOT_FOUND);
        }
        const data = snapshot.data();
        if (!models_1.isGame(data)) {
            throw new Error(exports.GAME_CORRUPT);
        }
        // @ts-ignore (casting data to Game)
        return data;
    });
}
exports.loadGame = loadGame;
//# sourceMappingURL=utils.js.map