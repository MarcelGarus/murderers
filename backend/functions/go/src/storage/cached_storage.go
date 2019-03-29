package storage

import (
	. "foundation"
	"github.com/google/go-cmp/cmp"
)

// CachedStorage is a storage that uses another storage and introduces the
// concepts of sessions.
// A new session can be created when a webhook is called and ended when the
// webhook finished. During a session, reads of he same data entries and writes
// to the same entry get merged into one read or write.
type CachedStorage struct {
	originalStorage Storage
	users           map[UserID]User
	originalUsers   map[UserID]User
	games           map[GameCode]Game
	originalGames   map[GameCode]Game
	players         map[GameCode]map[UserID]Player
	originalPlayers map[GameCode]map[UserID]Player
}

// NewCachedStorageSession creates a new CachedStorage.
func NewCachedStorageSession(s Storage) CachedStorage {
	return CachedStorage{
		originalStorage: s,
		users:           make(map[UserID]User),
		games:           make(map[GameCode]Game),
		players:         make(map[UserID]map[UserID]Player),
	}
}

// LoadUser loads a user from the cache, if posible.
func (s *CachedStorage) LoadUser(id UserID) (User, RichError) {
	var user User
	var ok bool
	var err RichError

	if user, ok = s.users[id]; ok {
		return user, nil
	}
	if user, err = s.originalStorage.LoadUser(id); err != nil {
		return User{}, err
	}
	s.users[id] = user
	s.originalUsers[id] = user
	return user, nil
}

// SaveUser saves a user to cache.
func (s *CachedStorage) SaveUser(user User) RichError {
	s.users[user.ID] = user
	return nil
}

// LoadGame loads a game from memory.
func (s *CachedStorage) LoadGame(code GameCode) (Game, RichError) {
	var game Game
	var ok bool
	var err RichError

	if game, ok = s.games[code]; ok {
		return game, nil
	}
	if game, err = s.originalStorage.LoadGame(code); err != nil {
		return Game{}, err
	}
	s.games[code] = game
	s.originalGames[code] = game
	return game, nil
}

// SaveGame saves a game to memory.
func (s *CachedStorage) SaveGame(game Game) RichError {
	s.games[game.Code] = game
	return nil
}

// LoadPlayer loads a player from memory.
func (s *CachedStorage) LoadPlayer(code GameCode, id UserID) (Player, RichError) {
	var player Player
	var err RichError

	if players, ok := s.players[code]; ok {
		if player, ok = players[id]; ok {
			return player, nil
		}
	}
	if player, err = s.originalStorage.LoadPlayer(code, id); err != nil {
		return Player{}, err
	}
	s.players[code][id] = player
	s.originalPlayers[code][id] = player
	return player, nil
}

// SavePlayer saves a player to memory.
func (s *CachedStorage) SavePlayer(player Player) RichError {
	s.players[player.Code][player.User.ID] = player
	return nil
}

// EndSession ends a session by synchronizing all the data that changed with the
// original storage.
func (s *CachedStorage) EndSession() RichError {
	// Synchronize users.
	for _, user := range s.users {
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
	for _, game := range s.games {
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
	for code, players := range s.players {
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
