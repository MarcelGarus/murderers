"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function isUser(obj) {
    return obj !== undefined // TODO: check authToken
        && typeof obj.messagingToken === "string"
        && typeof obj.name === "string";
}
exports.isUser = isUser;
exports.PLAYER_IDLE = 0;
exports.PLAYER_WAITING = 1;
exports.PLAYER_ALIVE = 2;
exports.PLAYER_DYING = 3;
exports.PLAYER_DEAD = 4;
function isPlayer(obj) {
    return obj !== undefined
        && typeof obj.state === "number"
        && (obj.murderer === null || typeof obj.murderer === "string")
        && (obj.victim === null || typeof obj.victim === "string")
        && typeof obj.wasOutsmarted === "boolean"
        && true // TODO: check all the deaths are deaths
        && typeof obj.kills === "number";
}
exports.isPlayer = isPlayer;
function isDeath(obj) {
    return obj !== undefined
        && typeof obj.time === "number"
        && typeof obj.murderer === "string"
        && typeof obj.lastWords === "string"
        && typeof obj.weapon === "string";
}
exports.isDeath = isDeath;
exports.GAME_NOT_STARTED_YET = 0;
exports.GAME_RUNNING = 1;
exports.GAME_PAUSED = 2;
exports.GAME_OVER = 3;
function isGame(obj) {
    return obj !== undefined
        && typeof obj.name === "string"
        && typeof obj.state === "number"
        && typeof obj.creator === "string"
        && typeof obj.created === "number"
        && typeof obj.start === "number"
        && typeof obj.end === "number";
}
exports.isGame = isGame;
//# sourceMappingURL=models.js.map