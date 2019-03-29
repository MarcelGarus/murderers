package storage

import (
	. "foundation"
)

// The InMemoryStorage can be interpreted as a CachedStorageSession that never
// ends.

// NewInMemoryStorage creates a new InMemoryStorage.
func NewInMemoryStorage() CachedStorage {
	return NewCachedStorageSession(&noStorage{})
}

type noStorage struct{}

func (s *noStorage) LoadUser(id UserID) (User, RichError) {
	return User{}, UserNotFoundError(id)
}

func (s *noStorage) SaveUser(user User) RichError {
	return nil
}

func (s *noStorage) DeleteUser(user User) RichError {
	return nil
}

func (s *noStorage) LoadGame(code GameCode) (Game, RichError) {
	return Game{}, GameNotFoundError(code)
}

func (s *noStorage) SaveGame(game Game) RichError {
	return nil
}

func (s *noStorage) DeleteGame(game Game) RichError {
	return nil
}

func (s *noStorage) LoadPlayer(code GameCode, id UserID) (Player, RichError) {
	return Player{}, PlayerNotFoundError(code, id)
}

func (s *noStorage) SavePlayer(player Player) RichError {
	return nil
}

func (s *noStorage) DeletePlayer(player Player) RichError {
	return nil
}
