package storage

/*import (
	"fmt"
	"testing"
)

func TestStorage(t *testing.T) {
	fmt.Println("Testing the in memory storage")
	inMemory := NewInMemoryStorage()
	testStorage(t, &inMemory)
}

func testStorage(t *testing.T, s Storage) {
	// Try to load a non-existing user.
	user, err := s.LoadUser(UserId("hey"))
	if err == nil {
		t.Error("User loaded although it shouldn't exist yet.")
	}

	// Create a user.
	user = User{
		Id: UserId("hey"),
	}
	err = s.SaveUser(user)
	if err != nil {
		t.Errorf("User couldn't be created: %s", err)
	}

	// Check that the user now exists.
	user, err = s.LoadUser(UserId("hey"))
	if err != nil {
		t.Errorf("User couldn't be loaded: %s", err)
	}

	// Try to load a non-existing game.
	game, err := s.LoadGame(GameCode("hey"))
	if err == nil {
		t.Error("Game loaded although it shouldn't exist yet.")
	}

	// Create a game.
	game = Game{
		Code: GameCode("hey"),
	}
	err = s.SaveGame(game)
	if err != nil {
		t.Errorf("Game couldn't be created: %s", err)
	}

	// Check that the game now exists.
	game, err = s.LoadGame(GameCode("hey"))
	if err != nil {
		t.Errorf("Game couldn't be loaded: %s", err)
	}
}*/
