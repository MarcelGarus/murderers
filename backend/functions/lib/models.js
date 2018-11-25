"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function isPlayer(obj) {
    console.log('Auth token valid? ' + (typeof obj.authToken === "string"));
    console.log('Name valid? ' + (typeof obj.name === "string"));
    console.log('Victim valid? ' + (obj.victim === null || typeof obj.victim === "string"));
    console.log('Death valid? ' + (obj.death === null || isDeath(obj.death)));
    return typeof obj.authToken === "string"
        && typeof obj.messagingToken === "string"
        && typeof obj.name === "string"
        && (obj.victim === null || typeof obj.victim === "string")
        && (obj.death === null || isDeath(obj.death));
}
exports.isPlayer = isPlayer;
function isAlive(obj) {
    return isPlayer(obj) && obj.death === null;
}
exports.isAlive = isAlive;
function isDeath(obj) {
    return typeof obj.murderer === "string"
        && typeof obj.lastWords === "string"
        && typeof obj.weapon === "string";
}
exports.isDeath = isDeath;
exports.GAME_NOT_STARTED_YET = 0;
exports.GAME_RUNNING = 1;
exports.GAME_PAUSED = 2;
exports.GAME_OVER = 3;
function isGame(obj) {
    return typeof obj.creator === "number"
        && typeof obj.name === "string"
        && typeof obj.state === "number";
    //&& typeof obj.start === "Date"
    //&& typeof obj.end === "Date"; TODO: check if it's dates
}
exports.isGame = isGame;
//# sourceMappingURL=models.js.map