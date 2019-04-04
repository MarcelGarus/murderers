package bloc

import (
	"fmt"
	"murderers/context"
	. "murderers/foundation"
	"murderers/storage"
	"testing"
	"time"
)

func TestActions(t *testing.T) {
	fmt.Println("Testing the bloc")

	// Creating a context.
	cStorage := storage.NewInMemoryStorage()
	c := context.New(
		&cStorage,
	)

	alphabet := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	// Create some users.
	users := make([]User, 0)
	for i := 0; i < 10; i++ {
		id := generateRandomString(alphabet, 10)
		user, err := CreateUser(&c, id, id, "messagingToken")
		if err != nil {
			t.Errorf("User couldn't be created: %s", err)
		}
		users = append(users, user)
	}
	creator := users[0]

	// Create a game.
	game, err := CreateGame(&c, creator.ID, creator.FirebaseID, "Sample game", time.Now())
	if err != nil {
		t.Errorf("Game couldn't be created: %s", err)
	}

	// Join players.
	err = JoinGame(&c, creator.ID, creator.FirebaseID, game.Code)
	if err != nil {
		t.Errorf("Error while joining the game: %s", err)
	}
	for i := 1; i < 8; i++ {
		err = JoinGame(&c, users[i].ID, users[i].FirebaseID, game.Code)
		if err != nil {
			t.Errorf("Error while joining the game: %s", err)
		}
		err = AcceptPlayers(&c, creator.ID, creator.FirebaseID, game.Code, []UserID{users[i].ID})
		if err != nil {
			t.Errorf("Error while accepting a player: %s", err)
		}
	}

	// Start the game.
	fmt.Println("Starting the game")
	err = StartGame(&c, game.Code, creator.ID, creator.FirebaseID)
	if err != nil {
		t.Errorf("Error while starting the game: %s", err)
	}

	// Kill a player.
	murderer, err := c.LoadPlayer(game.Code, users[1].ID)
	if err != nil {
		t.Errorf("Error occurred while loading a player: %s", err)
	}
	victim, err := c.LoadPlayerFromReference(murderer.Victim)
	if err != nil {
		t.Errorf("Error occurred while loading a player: %s", err)
	}
	err = KillPlayer(&c, murderer.User.ID, murderer.User.FirebaseID, game.Code, victim.User.ID)
	if err != nil {
		t.Errorf("Error while killing a player: %s", err)
	}
	err = Die(&c, victim.User.ID, victim.User.FirebaseID, game.Code, "Weapon", "Last words")
	if err != nil {
		t.Errorf("Error while dying: %s", err)
	}

	// Load all players.
	players, err := c.LoadAllPlayers(game.Code)
	if err != nil {
		t.Errorf("Error while getting all the players: %s", err)
	}
	t.Log(players)
}
