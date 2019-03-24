"use strict";
/// Utilities.
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
const util_1 = require("util");
const constants_1 = require("./constants");
/// Generates a length-long random string using the provided chars.
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
/// Checks if the query contains all the required parameters.
/// If not, sends a response (if res is not null) and returns false.
function queryContains(query, parameters, res) {
    for (const arg of parameters) {
        if (query[arg] === undefined || typeof query[arg] !== 'string' || query[arg] === '') {
            if (res !== null) {
                res.status(constants_1.CODE_BAD_REQUEST)
                    .send('Bad request. ' + arg + ' parameter missing.');
            }
            return false;
        }
    }
    return true;
}
exports.queryContains = queryContains;
/// Returns a Firestore reference to the user with the id.
function userRef(firestore, id) {
    return firestore.collection('users').doc(id);
}
exports.userRef = userRef;
/// Loads a user.
function loadUser(firestore, id, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (id === null || id === undefined || id === '') {
            if (res !== null) {
                res.status(constants_1.CODE_BAD_REQUEST).send('No user id provided.');
            }
            return null;
        }
        const snapshot = yield userRef(firestore, id).get();
        if (!snapshot.exists) {
            if (res !== null) {
                res.status(constants_1.CODE_USER_NOT_FOUND).send(constants_1.TEXT_USER_NOT_FOUND);
            }
            return null;
        }
        const data = snapshot.data();
        if (!models_1.isUser(data)) {
            if (res !== null) {
                res.status(constants_1.CODE_USER_CORRUPT).send(constants_1.TEXT_USER_CORRUPT);
            }
            util_1.log('Corrupt user: ' + JSON.stringify(data));
            return null;
        }
        return data;
    });
}
exports.loadUser = loadUser;
/// Loads and verifies the user with the id.
function loadAndVerifyUser(firestore, id, providedAuthToken, res) {
    return __awaiter(this, void 0, void 0, function* () {
        const user = yield loadUser(firestore, id, res);
        if (user === null)
            return null;
        if (user.authToken !== providedAuthToken) {
            if (res !== null) {
                res.status(constants_1.CODE_AUTHENTIFICATION_FAILED)
                    .send(constants_1.TEXT_AUTHENTIFICATION_FAILED);
            }
            return null;
        }
        return user;
    });
}
exports.loadAndVerifyUser = loadAndVerifyUser;
/// Verifies that the user is the creator of the game. 
function verifyCreator(game, userId, res) {
    if (game.creator === userId) {
        return true;
    }
    res.status(constants_1.CODE_NO_PRIVILEGES).send(constants_1.TEXT_NO_PRIVILEGES);
    return false;
}
exports.verifyCreator = verifyCreator;
/// Returns a Firestore reference to the game with the code.
function gameRef(firestore, code) {
    return firestore.collection('games').doc(code);
}
exports.gameRef = gameRef;
/// Loads a game with the code.
/// If errors occur, they are handled and the function just returns null.
function loadGame(res, firestore, code) {
    return __awaiter(this, void 0, void 0, function* () {
        if (code === null || code === undefined || code === '') {
            if (res !== null) {
                res.status(constants_1.CODE_BAD_REQUEST).send('You need to provide a game code.');
            }
            return null;
        }
        const snapshot = yield gameRef(firestore, code).get();
        if (!snapshot.exists) {
            res.status(constants_1.CODE_GAME_NOT_FOUND).send(constants_1.TEXT_GAME_NOT_FOUND);
            return null;
        }
        const data = snapshot.data();
        if (!models_1.isGame(data)) {
            res.status(constants_1.CODE_GAME_CORRUPT).send(constants_1.TEXT_GAME_CORRUPT);
            util_1.log('Corrupt game: ' + JSON.stringify(data));
            return null;
        }
        return data;
    });
}
exports.loadGame = loadGame;
/// Returns a Firestore reference to the collection of players of the game
/// with the code.
function allPlayersRef(firestore, code) {
    return gameRef(firestore, code).collection('players');
}
exports.allPlayersRef = allPlayersRef;
/// Returns a Firestore reference to the player with the id.
function playerRef(firestore, code, id) {
    return allPlayersRef(firestore, code).doc(id);
}
exports.playerRef = playerRef;
/// Loads a player with the id of the game with the code.
/// If errors occur, they are handled and the function just returns null.
function loadPlayer(res, firestore, code, id) {
    return __awaiter(this, void 0, void 0, function* () {
        if (id === null || id === undefined || id === '') {
            if (res !== null) {
                res.status(constants_1.CODE_BAD_REQUEST).send('No player id provided.');
            }
            return null;
        }
        const snapshot = yield playerRef(firestore, code, id).get();
        if (!snapshot.exists) {
            res.status(constants_1.CODE_PLAYER_NOT_FOUND).send(constants_1.TEXT_PLAYER_NOT_FOUND);
            util_1.log('Player with id ' + id + ' not found in game ' + code + '.');
            return null;
        }
        const data = snapshot.data();
        if (!models_1.isPlayer(data)) {
            res.status(constants_1.CODE_PLAYER_CORRUPT).send(constants_1.TEXT_PLAYER_CORRUPT);
            util_1.log('Corrupt player: ' + JSON.stringify(data));
            return null;
        }
        return data;
    });
}
exports.loadPlayer = loadPlayer;
/// Loads all player of a game with their ids.
/// If errors occur, they are handled and the function just returns null.
function loadPlayersAndIds(res, snapshotPromise) {
    return __awaiter(this, void 0, void 0, function* () {
        const players = [];
        const snapshot = yield snapshotPromise;
        let success = true;
        snapshot.forEach(doc => {
            const data = doc.data();
            if (models_1.isPlayer(data)) {
                players.push({
                    id: doc.id,
                    data: data
                });
            }
            else {
                res.status(constants_1.CODE_PLAYER_CORRUPT).send(constants_1.TEXT_PLAYER_CORRUPT);
                util_1.log('Corrupt player: ' + JSON.stringify(data));
                success = false;
            }
        });
        return success ? players : null;
    });
}
exports.loadPlayersAndIds = loadPlayersAndIds;
//# sourceMappingURL=utils.js.map