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
// TODO: handle no id and code given
function handleRequest(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!utils_1.queryContains(req.query, [
            'code'
        ], res))
            return;
        const firestore = admin.app().firestore();
        let id = req.query.id;
        let authToken = req.query.authToken;
        const code = req.query.code + '';
        // Load the game.
        const game = yield utils_1.loadGame(res, firestore, code);
        if (game === null)
            return;
        // Load the user.
        const user = yield utils_1.loadAndVerifyUser(firestore, id, authToken, null);
        if (user === null) {
            id = null;
            authToken = null;
        }
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
            creator: game.creator,
            end: game.end,
            players: players.map((playerAndId, _, __) => {
                const playerId = playerAndId.id;
                const player = playerAndId.data;
                const death = player.death;
                const isMe = (playerId === id);
                return {
                    id: isMe ? id : playerId,
                    name: isMe ? user.name : playerUsers[playerId].name,
                    state: player.state,
                    murderer: isMe ? player.murderer : null,
                    victim: isMe ? player.victim : null,
                    wasOutsmarted: isMe ? player.wasOutsmarted : null,
                    death: death === null ? null : {
                        time: death.time,
                        murderer: isMe ? death.murderer : null,
                        weapon: death.weapon,
                        lastWords: death.lastWords,
                    },
                    kills: player.kills
                };
            })
        });
    });
}
exports.handleRequest = handleRequest;
//# sourceMappingURL=get_game.js.map