"use strict";
/// Joins a player to a game.
///
/// Needs:
/// * a player name
///
/// Returns either:
/// 200: { id: 'abcdefghiojklmonop', authToken: 'dfsiidfsd' }
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
const utils_1 = require("./utils");
const PLAYER_ID_CHARS = 'abcdefghiojklnopqrstuvwxyz0123456789';
const PLAYER_ID_LENGTH = 2;
const AUTH_TOKEN_CHARS = 'abcdefghiojklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
const AUTH_TOKEN_LENGTH = 16;
/// Creates a new player id.
// TODO: make sure id doesn't already exist
// TODO: use analytics to log how many tries were needed
function createPlayerId() {
    return __awaiter(this, void 0, void 0, function* () {
        const id = utils_1.generateRandomString(PLAYER_ID_CHARS, PLAYER_ID_LENGTH);
        return id;
    });
}
/// Creates a new auth token.
function createAuthToken() {
    return utils_1.generateRandomString(AUTH_TOKEN_CHARS, AUTH_TOKEN_LENGTH);
}
/// Joins a player to a game.
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        console.log('Request query is ' + JSON.stringify(req.query));
        // Get a reference to the database and the game code.
        const db = admin.app().firestore();
        const code = req.query.code + '';
        let game;
        console.log('Joining the game ' + code + '.');
        // Try to load the game.
        try {
            game = yield utils_1.loadGame(db, code);
        }
        catch (error) {
            console.log("Joining the game failed, because the game couldn't be loaded. Error is:");
            console.log(error);
            if (true) { // TODO: check error message
                res.status(404).send('Game not found.');
            }
            else {
                res.status(500).send('Game corrupt.');
            }
        }
        // Game loaded successfully. Now join it.
        console.log('Game to join is ' + game);
        const player = {
            authToken: createAuthToken(),
            name: 'Marcel',
            victim: null,
            death: null
        };
        const id = yield createPlayerId();
        yield db
            .collection('games')
            .doc(code)
            .collection('players')
            .doc(id)
            .set(player);
        // Send back the player id and the authToken.
        res.set('application/json').send({
            id: id,
            authToken: player.authToken,
        });
        // TODO: Also send a notification to _all_ members of the game that opted in for notifications about new players.
        var message = {
            notification: {
                title: 'Someone just joined the game ' + code,
                body: 'Say hi by killing ' + id + '!',
            },
            android: {
                priority: 'normal',
                notification: {
                    color: '#ff0000',
                },
            },
            token: 'emd1IxAjbQg:APA91bF7MNO65rvy3Pg_XGEkJPHNdCSLpmahmreQYYRVEAzsIXaeg2XQNdRUHphERXzAX8WTRXnEEdisiMNsWoTQF-ee5HHDN8Gn1TIfF0MVxDbWso21JxDJt5-9-QtVUc2Jfe6EJYq7'
        };
        admin.messaging().send(message)
            .then((response) => {
            // Response is a message ID string.
            console.log('Successfully sent message:', response);
        })
            .catch((error) => {
            console.log('Error sending message:', error);
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=join_game.js.map