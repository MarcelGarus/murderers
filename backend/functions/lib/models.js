"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function isUser(obj) {
    return obj !== undefined
        && typeof obj.authToken === "string"
        && typeof obj.messagingToken === "string"
        && typeof obj.name === "string";
}
exports.isUser = isUser;
exports.PLAYER_JOINING = 0;
exports.PLAYER_ALIVE = 1;
exports.PLAYER_DYING = 2;
exports.PLAYER_DEAD = 3;
function isPlayer(obj) {
    return obj !== undefined
        && typeof obj.state === "number"
        && typeof obj.kills === "number"
        && (obj.murderer === null || typeof obj.murderer === "string")
        && (obj.victim === null || typeof obj.victim === "string")
        && typeof obj.wantsNewVictim === "boolean"
        && (obj.death === null || isDeath(obj.death));
}
exports.isPlayer = isPlayer;
function isDeath(obj) {
    return obj !== undefined
        && obj !== null
        && typeof obj.time === "number"
        && typeof obj.murderer === "string"
        && typeof obj.lastWords === "string"
        && typeof obj.weapon === "string";
}
exports.isDeath = isDeath;
exports.GAME_NOT_STARTED_YET = 0;
exports.GAME_RUNNING = 1;
exports.GAME_OVER = 2;
function isGame(obj) {
    return obj !== undefined
        && typeof obj.name === "string"
        && typeof obj.state === "number"
        && typeof obj.creator === "string"
        && typeof obj.created === "number"
        && typeof obj.end === "number";
}
exports.isGame = isGame;
//# sourceMappingURL=models.js.map