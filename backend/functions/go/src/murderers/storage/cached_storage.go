package storage

import (
	"github.com/google/go-cmp/cmp"
	"github.com/jinzhu/copier"
	. "murderers/foundation"
)

// CachedStorage is a storage that uses another storage and introduces the
// concepts of sessions.
// A new session can be created when a webhook is called and ended when the
// webhook finished. During a session, reads of he same data entries and writes
// to the same entry get merged into one read or write.
type CachedStorage struct {
	originalStorage Storage
	cachedUsers     map[UserID]User
	cachedGames     map[GameCode]Game
	cachedPlayers   map[GameCode]map[UserID]Player
	originalUsers   map[UserID]User
	originalGames   map[GameCode]Game
	originalPlayers map[GameCode]map[UserID]Player
}

// NewCachedStorageSession creates a new CachedStorage.
func NewCachedStorageSession(s Storage) CachedStorage {
	return CachedStorage{
		originalStorage: s,
		cachedUsers:     make(map[UserID]User),
		cachedGames:     make(map[GameCode]Game),
		cachedPlayers:   make(map[GameCode]map[UserID]Player),
		originalUsers:   make(map[UserID]User),
		originalGames:   make(map[GameCode]Game),
		originalPlayers: make(map[GameCode]map[UserID]Player),
	}
}

// LoadUser loads a user from the cache, if posible.
func (s *CachedStorage) LoadUser(id UserID) (*User, RichError) {
	if user, ok := s.cachedUsers[id]; ok {
		return &user, nil
	}

	user, err := s.originalStorage.LoadUser(id)
	if err != nil {
		return nil, err
	}

	s.cachedUsers[id] = *user
	s.originalUsers[id] = *user

	var copyOfUser User
	copier.Copy(user, copyOfUser)
	return &copyOfUser, nil
}

// SaveUser saves a user to cache.
func (s *CachedStorage) SaveUser(user User) RichError {
	s.cachedUsers[user.ID] = user
	return nil
}

// DeleteUser deletes a user from the cache.
func (s *CachedStorage) DeleteUser(user User) RichError {
	delete(s.cachedUsers, user.ID)
	return nil
}

// LoadGame loads a game from memory.
func (s *CachedStorage) LoadGame(code GameCode) (*Game, RichError) {
	if game, ok := s.cachedGames[code]; ok {
		return &game, nil
	}

	game, err := s.originalStorage.LoadUser(code)
	if err != nil {
		return nil, err
	}

	s.cachedUsers[code] = *game
	s.originalUsers[code] = *game

	var copyOfGame Game
	copier.Copy(game, copyOfGame)
	return &copyOfGame, nil
}

// SaveGame saves a game to memory.
func (s *CachedStorage) SaveGame(game Game) RichError {
	s.cachedGames[game.Code] = game
	return nil
}

// DeleteGame deletes a game from the cache.
func (s *CachedStorage) DeleteGame(game Game) RichError {
	delete(s.cachedGames, game.Code)
	return nil
}

// LoadPlayer loads a player from memory.
func (s *CachedStorage) LoadPlayer(code GameCode, id UserID) (*Player, RichError) {
	if players, ok := s.cachedPlayers[code]; ok {
		if player, ok := players[id]; ok {
			return &player, nil
		}
	}

	player, err := s.originalStorage.LoadPlayer(code, id)
	if err != nil {
		return nil, err
	}

	s.cachedPlayers[code][id] = *player
	s.originalPlayers[code][id] = *player

	var copyOfPlayer Player
	copier.Copy(player, copyOfPlayer)
	return &copyOfPlayer, nil
}

// SavePlayer saves a player to memory.
func (s *CachedStorage) SavePlayer(player Player) RichError {
	if _, found := s.cachedPlayers[player.Code]; !found {
		s.cachedPlayers[player.Code] = make(map[UserID]Player)
	}
	s.cachedPlayers[player.Code][player.User.ID] = player
	return nil
}

// DeletePlayer deletes a user from the cache.
func (s *CachedStorage) DeletePlayer(player Player) RichError {
	delete(s.cachedPlayers[player.Code], player.User.ID)
	return nil
}

// EndSession ends a session by synchronizing all the data that changed with the
// original storage.
func (s *CachedStorage) EndSession() RichError {
	// Synchronize users.
	for _, user := range s.cachedUsers {
		originalUser, found := s.originalUsers[user.ID]
		if !found || user != originalUser {
			if err := s.originalStorage.SaveUser(user); err != nil {
				return err
			}
		}
		delete(s.originalUsers, user.ID)
	}
	for _, user := range s.originalUsers {
		if err := s.originalStorage.DeleteUser(user); err != nil {
			return err
		}
	}

	// Synchronize games.
	for _, game := range s.cachedGames {
		originalGame, found := s.originalGames[game.Code]
		if !found || cmp.Equal(game, originalGame) {
			if err := s.originalStorage.SaveGame(game); err != nil {
				return err
			}
		}
		delete(s.originalGames, game.Code)
	}
	for _, game := range s.originalGames {
		if err := s.originalStorage.DeleteGame(game); err != nil {
			return err
		}
	}

	// Synchronize players.
	for code, players := range s.cachedPlayers {
		for _, player := range players {
			originalPlayer, found := s.originalPlayers[code][player.User.ID]
			if !found || cmp.Equal(player, originalPlayer) {
				if err := s.originalStorage.SavePlayer(player); err != nil {
					return err
				}
			}
			delete(s.originalPlayers[code], player.User.ID)
		}
		for _, player := range s.originalPlayers[code] {
			if err := s.originalStorage.DeletePlayer(player); err != nil {
				return err
			}
		}
	}

	return nil
}
