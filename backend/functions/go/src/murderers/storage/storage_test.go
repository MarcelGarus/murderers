package storage

import (
	. "murderers/foundation"
	"testing"
	"time"
)

func TestStorage(t *testing.T) {
	inMemory := NewInMemoryStorage()
	testStorage(t, &inMemory)

	inMemory = NewInMemoryStorage()
	cached := NewCachedStorageSession(&inMemory)
	testStorage(t, &cached)
	cached.EndSession()
}

func testStorage(t *testing.T, s Storage) {
	testUserStorage(t, s)
	testGameStorage(t, s)
	testPlayerStorage(t, s)
}

func testUserStorage(t *testing.T, s Storage) {
	user := createSampleUser()

	// Try to load a non-existing user.
	if _, err := s.LoadUser(user.ID); err == nil {
		t.Error("User loaded although it shouldn't exist")
	}

	// Create a user.
	if err := s.SaveUser(user); err != nil {
		t.Errorf("User couldn't be created: %s", err)
	}

	// Ensure that the user now exists.
	if _, err := s.LoadUser(user.ID); err != nil {
		t.Errorf("User couldn't be loaded: %s", err)
	}

	// Delete the user.
	if err := s.DeleteUser(user); err != nil {
		t.Errorf("User couldn't be deleted: %s", err)
	}

	// Ensure that the user doesn't exist anymore.
	if _, err := s.LoadUser(user.ID); err == nil {
		t.Errorf("The user exists after it's been deleted.")
	}
}

func testGameStorage(t *testing.T, s Storage) {
	game := createSampleGame()

	// Try to load a game.
	if _, err := s.LoadGame(game.Code); err == nil {
		t.Error("Game loaded although it shouldn't exist.")
	}

	// Create a game.
	if err := s.SaveGame(game); err != nil {
		t.Errorf("Game couldn't be created: %s", err)
	}

	// Ensure that the game now exists.
	if _, err := s.LoadGame(game.Code); err != nil {
		t.Errorf("Game couldn't be loaded: %s", err)
	}

	// Delete the game.
	if err := s.DeleteGame(game); err != nil {
		t.Errorf("Game couldn't be deleted: %s", err)
	}

	// Ensure that the user doesn't exist anymore.
	if _, err := s.LoadGame(game.Code); err == nil {
		t.Errorf("The game exists after it's been deleted.")
	}
}

func testPlayerStorage(t *testing.T, s Storage) {
	game := createSampleGame()
	player := createSamplePlayer()

	// Try to load a non-existent player.
	if _, err := s.LoadPlayer(game.Code, player.User.ID); err == nil {
		t.Error("Player loaded although it shouldn't exist.")
	}

	// Create a game.
	if err := s.SaveGame(game); err != nil {
		t.Errorf("Game couldn't be created: %s", err)
	}

	// Ensure that the game now exists.
	if _, err := s.LoadGame(GameCode("game")); err != nil {
		t.Errorf("Game couldn't be loaded: %s", err)
	}

	// Delete the user.
	if err := s.DeletePlayer(player); err != nil {
		t.Errorf("Game couldn't be deleted: %s", err)
	}

	// Ensure that the user doesn't exist anymore.
	if _, err := s.LoadPlayer(game.Code, player.User.ID); err == nil {
		t.Errorf("The game exists after it's been deleted.")
	}
}

func createSampleUser() User {
	return User{
		ID:             UserID("marcel"),
		FirebaseID:     "firebaseID",
		MessagingToken: "messagingToken",
		Name:           "Marcel",
	}
}

func createSampleGame() Game {
	return Game{
		Code:    GameCode("game"),
		Name:    "A game.",
		State:   GameNotStartedYet,
		Creator: createSampleUser(),
		Created: time.Now(),
		End:     time.Now(),
		Joining: make(map[UserID]bool),
	}
}

func createSamplePlayer() Player {
	return Player{
		Code:           createSampleGame().Code,
		User:           createSampleUser(),
		State:          PlayerAlive,
		Murderer:       PlayerReference{},
		Victim:         PlayerReference{},
		WantsNewVictim: false,
		Death:          Death{},
		Kills:          0,
	}
}
