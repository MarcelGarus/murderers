/// Models that are used throughout the backend.

/// A user of the app.
/// May be participating in multiple games as player, watcher or creator.
export interface User {
  id: string,
	name:	string,
};

/// A game.
export interface Game {
  code: string,
  isRunning: boolean,
  start: number,
  end: number,
}
