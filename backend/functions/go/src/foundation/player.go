package foundation

import (
	"time"
)

// Player represents a player of a game.
type Player struct {
	Code           GameCode
	User           User
	State          PlayerState
	Murderer       PlayerReference
	Victim         PlayerReference
	WantsNewVictim bool
	Deaths         []Death
	Kills          int
}

// PlayerState represents the state of the player.
type PlayerState = int

const (
	// PlayerAlive indicates the player is alive.
	PlayerAlive = PlayerState(iota)

	// PlayerDying indicates the player got killed, but still needs to confirm
	// its death.
	PlayerDying = PlayerState(iota)

	// PlayerDead indicates the player is dead.
	PlayerDead = PlayerState(iota)
)

// ToReference turns the player into a reference of itself.
func (player Player) ToReference() PlayerReference {
	return PlayerReference{
		code: player.Code,
		id:   player.User.ID,
	}
}

// PlayerReference references a player by holding its code and id.
type PlayerReference struct {
	code GameCode
	id   UserID
}

// Death describes how a player died.
type Death struct {
	time      time.Time
	murderer  PlayerReference
	weapon    string
	lastWords string
}
