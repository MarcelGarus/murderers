/// Models that are used throughout the backend.

export type GameCode = string;
export type PlayerId = string;
export type AuthToken = string;

/// A player in a game.
export interface Player {
  authToken: AuthToken, // Token that the player can use to do stuff.
  name: string,
  isAlive: boolean,
  victim: PlayerId,
}

export function isPlayer(obj): boolean {
  return true; // TODO
}

/// A game.
export interface Game {
  name: string,
  isRunning: boolean,
  start: number,
  end: number,
  creatorId: number, // Google Sign In ID
}

export function isGame(obj): boolean {
  // TODO
  return typeof obj.isRunning === "boolean"
    && typeof obj.start === "number"
    && typeof obj.end === "number";
}
