package storage

import . "murderers/foundation"

// Storage is a system that allows for saving and loading top-level users and
// games as well as players for every game.
type Storage interface {
	LoadUser(id UserID) (User, RichError)
	SaveUser(user User) RichError
	DeleteUser(user User) RichError
	LoadGame(code GameCode) (Game, RichError)
	SaveGame(game Game) RichError
	DeleteGame(game Game) RichError
	LoadPlayer(code GameCode, id UserID) (Player, RichError)
	SavePlayer(player Player) RichError
	DeletePlayer(player Player) RichError
}
