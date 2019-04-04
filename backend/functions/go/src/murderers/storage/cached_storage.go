package storage

import (
	"fmt"
	"github.com/google/go-cmp/cmp"
	. "murderers/foundation"
)

// CachedStorage is a storage that uses another storage and introduces the
// concepts of sessions.
// A new session can be created when a webhook is called and ended when the
// webhook finished. During a session, reads of he same data entries and writes
// to the same entry get merged into one read or write.
type CachedStorage struct {
	originalStorage                Storage
	cachedUsers                    map[UserID]User
	cachedGames                    map[GameCode]Game
	cachedPlayers                  map[GameCode]map[UserID]Player
	originalUsers                  map[UserID]User
	originalGames                  map[GameCode]Game
	originalPlayers                map[GameCode]map[UserID]Player
	allPlayersLoaded               map[GameCode]bool
	playersWhoWantNewVictimsLoaded map[GameCode]bool
}

// NewCachedStorageSession creates a new CachedStorage.
func NewCachedStorageSession(s Storage) CachedStorage {
	return CachedStorage{
		originalStorage:                s,
		cachedUsers:                    make(map[UserID]User),
		cachedGames:                    make(map[GameCode]Game),
		cachedPlayers:                  make(map[GameCode]map[UserID]Player),
		originalUsers:                  make(map[UserID]User),
		originalGames:                  make(map[GameCode]Game),
		originalPlayers:                make(map[GameCode]map[UserID]Player),
		allPlayersLoaded:               make(map[GameCode]bool),
		playersWhoWantNewVictimsLoaded: make(map[GameCode]bool),
	}
}

// LoadUser loads a user from the cache, if posible.
func (s *CachedStorage) LoadUser(id UserID) (User, RichError) {
	// If possible, use the cached version.
	if user, ok := s.cachedUsers[id]; ok {
		return user, nil
	}

	// Otherwise, load it from the original storage.
	user, err := s.originalStorage.LoadUser(id)
	if err != nil {
		return User{}, err
	}

	// Save it.
	s.cachedUsers[id] = user
	s.originalUsers[id] = user

	return user, nil
}

// SaveUser saves a user to cache.
func (s *CachedStorage) SaveUser(user User) RichError {
	s.cachedUsers[user.ID] = user
	fmt.Printf("Saving user with id %s. Now, there are %d users.\n",
		user.ID, len(s.cachedUsers))
	return nil
}

// DeleteUser deletes a user from the cache.
func (s *CachedStorage) DeleteUser(user User) RichError {
	delete(s.cachedUsers, user.ID)
	return nil
}

// LoadGame loads a game from memory.
func (s *CachedStorage) LoadGame(code GameCode) (Game, RichError) {
	// If possible, use the cached version.
	if game, ok := s.cachedGames[code]; ok {
		return game, nil
	}

	// Otherwise, load it from the original storage.
	game, err := s.originalStorage.LoadGame(code)
	if err != nil {
		return Game{}, err
	}

	// Save it.
	s.cachedGames[code] = game
	s.originalGames[code] = game

	return game, nil
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
func (s *CachedStorage) LoadPlayer(code GameCode, id UserID) (Player, RichError) {
	// If possible, load the cached version.
	if players, ok := s.cachedPlayers[code]; ok {
		if player, ok := players[id]; ok {
			return player, nil
		}
	}

	// Otherwise, get it from the original storage.
	player, err := s.originalStorage.LoadPlayer(code, id)
	if err != nil {
		return Player{}, err
	}

	// Save it.
	s.cachedPlayers[code][id] = player
	s.originalPlayers[code][id] = player

	// Copy and return it.
	return player, nil
}

// LoadAllPlayers loads all players.
func (s *CachedStorage) LoadAllPlayers(code GameCode) ([]Player, RichError) {
	// Try to get the cached version.
	if isCached, ok := s.allPlayersLoaded[code]; ok && isCached {
		if allPlayers, ok := s.cachedPlayers[code]; ok {
			var players []Player
			for _, player := range allPlayers {
				players = append(players, player)
			}
			return players, nil
		}
		return make([]Player, 0), CorruptError()
	}

	// Otherwise, get it from the original storage.
	players, err := s.originalStorage.LoadAllPlayers(code)
	if err != nil {
		return make([]Player, 0), err
	}

	// Save it.
	cachedPlayers, ok := s.cachedPlayers[code]
	if !ok {
		cachedPlayers = make(map[UserID]Player, 0)
		s.cachedPlayers[code] = cachedPlayers
	}
	originalPlayers, ok := s.originalPlayers[code]
	if !ok {
		originalPlayers = make(map[UserID]Player, 0)
		s.originalPlayers[code] = originalPlayers
	}
	for _, player := range players {
		if _, ok := cachedPlayers[player.User.ID]; !ok {
			cachedPlayers[player.User.ID] = player
		}
		originalPlayers[player.User.ID] = player
	}
	s.allPlayersLoaded[code] = true
	s.playersWhoWantNewVictimsLoaded[code] = true

	// Turn map into list and return it.
	resultPlayers := make([]Player, 0)
	for _, player := range cachedPlayers {
		resultPlayers = append(resultPlayers, player)
	}
	return resultPlayers, nil
}

// LoadPlayersWhoWantNewVictims loads all the players who want new victims.
func (s *CachedStorage) LoadPlayersWhoWantNewVictims(code GameCode) ([]Player, RichError) {
	// Try to get the cached version.
	if isCached, ok := s.playersWhoWantNewVictimsLoaded[code]; ok && isCached {
		if allPlayers, ok := s.cachedPlayers[code]; ok {
			var players []Player
			for _, player := range allPlayers {
				if player.WantsNewVictim {
					players = append(players, player)
				}
			}
			return players, nil
		}
		return make([]Player, 0), CorruptError()
	}

	// Otherwise, get it from the original storage.
	players, err := s.originalStorage.LoadPlayersWhoWantNewVictims(code)
	if err != nil {
		return make([]Player, 0), err
	}

	// Save it.
	cachedPlayers, ok := s.cachedPlayers[code]
	if !ok {
		cachedPlayers = make(map[UserID]Player, 0)
		s.cachedPlayers[code] = cachedPlayers
	}
	originalPlayers, ok := s.originalPlayers[code]
	if !ok {
		originalPlayers = make(map[UserID]Player, 0)
		s.originalPlayers[code] = originalPlayers
	}
	for _, player := range players {
		if _, ok := cachedPlayers[player.User.ID]; !ok {
			cachedPlayers[player.User.ID] = player
		}
		originalPlayers[player.User.ID] = player
	}
	s.playersWhoWantNewVictimsLoaded[code] = true

	// Turn map into list and return it.
	resultPlayers := make([]Player, 0)
	for _, player := range cachedPlayers {
		resultPlayers = append(resultPlayers, player)
	}
	return resultPlayers, nil
}

// SavePlayer saves a player to memory.
func (s *CachedStorage) SavePlayer(player Player) RichError {
	players, found := s.cachedPlayers[player.Code]
	if !found {
		players = make(map[UserID]Player)
		s.cachedPlayers[player.Code] = players
	}
	players[player.User.ID] = player
	fmt.Printf("Saving player with code %s and id %s. Now, there are %d players.\n",
		player.Code, player.User.ID, len(players))
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
