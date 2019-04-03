package foundation

import "time"

// Player represents a player of a game.
type Player struct {
	Code           GameCode
	User           User
	State          PlayerState
	Murderer       PlayerReference
	Victim         PlayerReference
	WantsNewVictim bool
	Death          Death
	Kills          int
}

// PlayerState represents the state of the player.
type PlayerState = int

const (
	// PlayerAlive indicates the player is alive.
	PlayerAlive = 0

	// PlayerDying indicates the player got killed, but still needs to confirm
	// its death.
	PlayerDying = 1

	// PlayerDead indicates the player is dead.
	PlayerDead = 2

	// PlayerWon indicates that the player won the game (is the only one left).
	PlayerWon = 3
)

// ToReference turns the player into a reference of itself.
func (player Player) ToReference() PlayerReference {
	return PlayerReference{
		Code: player.Code,
		ID:   player.User.ID,
	}
}

// PlayerReference references a player by holding its code and id.
type PlayerReference struct {
	Code GameCode
	ID   UserID
}

// Death describes how a player died.
type Death struct {
	Time      time.Time
	Murderer  PlayerReference
	Weapon    string
	LastWords string
}
