"use strict";
/// Returns a game's state.
///
/// Needs:
/// * game [code]
/// Optional:
/// * user [id]
/// * [authToken]
///
/// Returns either:
/// 200: {
///   name: 'The game\'s name',
///   state: GameState.RUNNING,
///   created: 'Some google id',
///   end: 2222-12-22,
///   players: [
///     {
///       id: 'player-id',
///       name: 'Marcel',
///       death: {
///         ...
///       }
///     },
///     ...
///   ]
/// }
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
/// Returns a game's state.
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!utils_1.queryContains(req.query, [
            'code'
        ], res))
            return;
        const firestore = admin.app().firestore();
        const id = req.query.user;
        const authToken = req.query.authToken;
        const code = req.query.code + '';
        // Load the game.
        const game = yield utils_1.loadGame(res, firestore, code);
        if (game === null)
            return;
        // Load the user.
        const user = yield utils_1.loadAndVerifyUser(firestore, id, authToken, null);
        // Load the players.
        const players = yield utils_1.loadPlayersAndIds(res, utils_1.allPlayersRef(firestore, code).get());
        if (players === null)
            return;
        console.log("Players are " + JSON.stringify(players));
        // Load the other users.
        const playerUsers = new Map();
        for (const player of players) {
            if (player.id === id)
                continue;
            const playerUser = yield utils_1.loadUser(firestore, player.id, res);
            if (playerUser === null)
                return;
            playerUsers[player.id] = playerUser;
        }
        // Send back the game's state.
        res.set('application/json').send({
            name: game.name,
            state: game.state,
            created: game.created,
            end: game.end,
            players: players.map((player, _, __) => {
                if (player.id === id) {
                    // This is the player who requested the information.
                    // Provide detailed information.
                    return {
                        id: id,
                        name: user.name,
                        state: player.data.state,
                        murderer: player.data.murderer,
                        victim: player.data.victim,
                        wasOutsmarted: player.data.wasOutsmarted,
                        deaths: player.data.deaths.map((death, ___, ____) => {
                            return {
                                time: death.time,
                                murderer: death.murderer,
                                weapon: death.weapon,
                                lastWords: death.lastWords,
                            };
                        }),
                        kills: player.data.kills,
                    };
                }
                else {
                    // This is some other player.
                    // Only provide superficial information.
                    const playerUser = playerUsers[player.id];
                    return {
                        id: player.id,
                        name: playerUser.name,
                        state: player.data.state,
                        deaths: player.data.deaths.map((death, ___, ____) => {
                            return {
                                time: death.time,
                                weapon: death.weapon,
                                lastWords: death.lastWords,
                            };
                        }),
                    };
                }
            })
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=get_game.js.map