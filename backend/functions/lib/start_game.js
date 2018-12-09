"use strict";
/// Starts an existing game.
///
/// Needs:
/// * a Firebase auth in header
/// * a game id
///
/// Returns either:
/// 200: Game started.
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
/// Starts an existing game.
// TODO: check access
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        console.log('Request query is ' + JSON.stringify(req.query));
        // Get a reference to the database and the game code.
        const db = admin.app().firestore();
        const code = req.query.code + '';
        let game;
        // Try to load the game.
        try {
            game = yield utils_1.loadGame(db, code);
        }
        catch (error) {
            console.log("Starting the game failed, because the game couldn't be loaded. Error is:");
            console.log(error);
            if (true) { // TODO: check error message
                res.status(404).send(utils_1.GAME_NOT_FOUND);
            }
            else {
                res.status(500).send(utils_1.GAME_CORRUPT);
            }
        }
        // Game loaded successfully. Now start it.
        console.log('Game to start is ' + game);
        yield db
            .collection('games')
            .doc(code)
            .update({
            state: models_1.GAME_RUNNING
        });
        const snapshot = yield db
            .collection('games')
            .doc(code)
            .collection('players')
            .get();
        // Save all players.
        const players = [];
        snapshot.forEach(doc => {
            const data = doc.data();
            console.log(doc.id, '=>', data);
            if (models_1.isPlayer(data)) {
                players.push({
                    id: doc.id,
                    data: data
                });
            }
            else {
                console.log('Is not a player: ' + data);
            }
        });
        console.log('Players to shuffle and connect are ' + JSON.stringify(players));
        // Set the player's victims randomly.
        utils_1.shuffle(players);
        console.log('Shuffled players are ' + JSON.stringify(players));
        players.forEach((player, index) => {
            console.log('Setting the victim of player #' + index + ' (' + JSON.stringify(player) + ')');
            if (index === 0) {
                player.data.victim = players[players.length - 1].id;
            }
            else {
                player.data.victim = players[index - 1].id;
            }
        });
        players.forEach((player) => __awaiter(this, void 0, void 0, function* () {
            yield db
                .collection('games')
                .doc(code)
                .collection('players')
                .doc(player.id)
                .set(player.data);
        }));
        res.send('success');
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=start_game.js.map