/// A player.
///
/// The term player refers to all users participating in a game. Players only
/// exist in the context and scope of games - if a user plays in two games, he
/// is represented by two distinct players.
///
/// Each player has an id (not in this class) that's used as a reference to the
/// player in backend & frontend. The player class holds:
/// * [authToken]: An authentication token that allows the player to
///   authenticate himself to the server and take actions.
/// * [name]: The name of the player. May change during the course of the game.
/// * [victim]: The id of the player's victim. If no victim is chosen, it may
///   be null.
/// * [death]: Information about how the player died. If death is null, the
///   player lives.
export type PlayerId = string;
export type AuthToken = string;
export type MessagingToken = string;

export interface Player {
  authToken: AuthToken,
  messagingToken: MessagingToken,
  name: string,
  victim: PlayerId,
  death: Death,
}
export function isPlayer(obj): boolean {
  return typeof obj.authToken === "string"
    && typeof obj.messagingToken === "string"
    && typeof obj.name === "string"
    && (obj.victim === null || typeof obj.victim === "string")
    && (obj.death === null || isDeath(obj.death));
}
export function isAlive(obj): boolean {
  return isPlayer(obj) && obj.death === null;
}


/// A death.
///
/// A class that holds some information about how a player died. Victim refers
/// to the player who died, murderer refers to the player who killed the
/// victim. This class is owned by the victim.
///
/// This class holds:
/// * [murderer]: The id of the murderer.
/// * [lastWords]: The victim's last words. May be null if the game doesn't
///   support providing last words.
/// * [weapon]: The murderer's weapon. May be null if the game doesn't support
///   providing weapons.
export interface Death {
  murderer: PlayerId,
  lastWords: string,
  weapon: string,
}
export function isDeath(obj): boolean {
  return typeof obj.murderer === "string"
    && typeof obj.lastWords === "string"
    && typeof obj.weapon === "string";
}


/// A game.
///
/// A class that holds some information about the game in general.
///
/// Each game has a code (not in this class) that is unique in all the games
/// that didn't end yet. The game class holds:
/// * [creator]: The creator's GoogleSignInId that allows him to authenticate
///   himself to the server and change some of the game configuration.
/// * [name]: The name of the game.
/// * [state]: The state of the game.
/// * [created]: Timestamp when the game was created.
/// * [end]: The estimated timestamp of the game's end. May be changed by the
///   creator.
export type GameCode = string;
export type GoogleSignInId = number;
export type GameState = number;

export const GAME_NOT_STARTED_YET: GameState = 0;
export const GAME_RUNNING: GameState = 1;
export const GAME_PAUSED: GameState = 2;
export const GAME_OVER: GameState = 3;

export interface Game {
  creator: GoogleSignInId,
  name: string,
  state: GameState,
  created: number,
  end: number,
}
export function isGame(obj): boolean {
  return typeof obj.creator === "number"
    && typeof obj.name === "string"
    && typeof obj.state === "number";
    //&& typeof obj.start === "Date"
    //&& typeof obj.end === "Date"; TODO: check if it's dates
}
