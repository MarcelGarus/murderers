"use strict";
/// Returns a game's state.
///
/// Needs:
/// * a game code
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
const models_1 = require("./models");
const utils_1 = require("./utils");
/// Returns a game's state.
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        console.log('Request query is ' + JSON.stringify(req.query));
        // Get a reference to the database and the game code.
        const db = admin.app().firestore();
        const code = req.query.code + '';
        let game;
        console.log('Getting the game ' + code + '.');
        // Try to load the game.
        try {
            game = yield utils_1.loadGame(db, code);
        }
        catch (error) {
            console.log("The game couldn't be loaded. Error is:");
            console.log(error);
            if (true) { // TODO: check error message
                res.status(404).send('Game not found.');
            }
            else {
                res.status(500).send('Game corrupt.');
            }
        }
        // Load the players.
        const snapshot = yield db
            .collection('games')
            .doc(code)
            .collection('players')
            .get();
        let playerIds = [];
        let players = [];
        for (let doc of snapshot.docs) {
            const id = doc.id;
            const data = doc.data();
            console.log("Player has data " + JSON.stringify(data));
            if (!models_1.isPlayer(data)) {
                res.status(500).send('Player corrupt.');
                return;
            }
            else {
                playerIds.push(id);
                players.push(data);
            }
        }
        console.log("Players are " + JSON.stringify(players));
        // Send back the game's state.
        res.set('application/json').send({
            name: game.name,
            state: game.state,
            created: game.created,
            end: game.end,
            players: players.map((value, index, _) => {
                return {
                    id: playerIds[index],
                    name: value.name,
                    death: value.death
                };
            })
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=get_game.js.map