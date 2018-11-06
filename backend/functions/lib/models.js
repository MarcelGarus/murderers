"use strict";
/// Models that are used throughout the backend.
Object.defineProperty(exports, "__esModule", { value: true });
function isPlayer(obj) {
    return true; // TODO
}
exports.isPlayer = isPlayer;
function isGame(obj) {
    // TODO
    return typeof obj.isRunning === "boolean"
        && typeof obj.start === "number"
        && typeof obj.end === "number";
}
exports.isGame = isGame;
//# sourceMappingURL=models.js.map