package storage

import (
	"fmt"
	"utils"
)

/// A storage system that allows for saving top-level users and games as well as
/// players for every game.
type Storage interface {
	LoadUser(userId UserId) (User, ErrorWithStatus)
	SaveUser(user User) ErrorWithStatus
	LoadGame(gameCode GameCode) (Game, ErrorWithStatus)
	SaveGame(game Game) ErrorWithStatus
	LoadPlayer(gameCode GameCode, userId UserId) (Player, ErrorWithStatus)
	SavePlayer(player Player) ErrorWithStatus
}
