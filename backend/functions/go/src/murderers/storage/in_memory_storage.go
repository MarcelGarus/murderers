package storage

import . "murderers/foundation"

// The InMemoryStorage can be interpreted as a CachedStorageSession that never
// ends.

// NewInMemoryStorage creates a new InMemoryStorage.
func NewInMemoryStorage() CachedStorage {
	return NewCachedStorageSession(&noStorage{})
}

type noStorage struct{}

func (s *noStorage) LoadUser(id UserID) (*User, RichError) {
	return nil, UserNotFoundError(id)
}

func (s *noStorage) SaveUser(user User) RichError {
	return nil
}

func (s *noStorage) DeleteUser(user User) RichError {
	return nil
}

func (s *noStorage) LoadGame(code GameCode) (*Game, RichError) {
	return nil, GameNotFoundError(code)
}

func (s *noStorage) SaveGame(game Game) RichError {
	return nil
}

func (s *noStorage) DeleteGame(game Game) RichError {
	return nil
}

func (s *noStorage) LoadPlayer(code GameCode, id UserID) (*Player, RichError) {
	return nil, PlayerNotFoundError(code, id)
}

func (s *noStorage) SavePlayer(player Player) RichError {
	return nil
}

func (s *noStorage) DeletePlayer(player Player) RichError {
	return nil
}
