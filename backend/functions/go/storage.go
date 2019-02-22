package main

import (
	"fmt"
)

type Storage interface {
	LoadUser(id UserId) (User, error)
	SaveUser(user User) error
	LoadGame(id GameCode) (Game, error)
	SaveGame(game Game) error
	LoadPlayer(game Game, id UserId) (Player, error)
	SavePlayer(player Player) error
}

type UserNotFoundError UserId
func (id UserNotFoundError) Error() string {
	return fmt.Sprintf("storage: user with id %s not found", string(id))
}
type UserCorruptError UserId
func (id UserCorruptError) Error() string {
	return fmt.Sprintf("storage: user with id %s is corrupt", string(id))
}
type GameNotFoundError GameCode
func (code GameNotFoundError) Error() string {
	return fmt.Sprintf("storage: game with code %s not found", string(code))
}
type GameCorruptError UserId
func (id GameCorruptError) Error() string {
	return fmt.Sprintf("storage: game with id %s is corrupt", string(id))
}
