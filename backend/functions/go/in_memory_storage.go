package main

import (
	"errors"
)

type InMemoryStorage struct {
	users map[UserId]User
	games map[GameCode]Game
	players map[UserId]Player
}

func NewInMemoryStorage() InMemoryStorage {
	return InMemoryStorage{
		users: make(map[UserId]User),
		games: make(map[GameCode]Game),
		players: make(map[UserId]Player),
	}
}

func (s* InMemoryStorage) LoadUser(id UserId) (User, error) {
	var user User
	if user, ok := s.users[id]; ok {
    return user, nil
	}
	return user, errors.New("storage: User not found.")
}

func (s* InMemoryStorage) SaveUser(user User) error {
	s.users[user.Id] = user
	return nil
}

func (s* InMemoryStorage) LoadGame(code GameCode) (Game, error) {
	var game Game
	if game, ok := s.games[code]; ok {
    return game, nil
	}
	return game, errors.New("storage: Game not found.")
}

func (s* InMemoryStorage) SaveGame(game Game) error {
	s.games[game.Code] = game
	return nil
}

func (s* InMemoryStorage) LoadPlayer(game Game, id UserId) (Player, error) {
	var player Player
	if player, ok := s.players[id]; ok {
    return player, nil
	}
	return player, errors.New("storage: Player not found.")
}

func (s* InMemoryStorage) SavePlayer(player Player) error {
	s.players[player.Id] = player
	return nil
}
