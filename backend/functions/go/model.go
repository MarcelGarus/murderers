package main

import (
	"time"
)

// A user. The user's id is also used as the id for associated players.
type UserId = string
type User struct {
	Id UserId
	AuthToken string
	MessagingToken string
	Name string
}

// A player. Players only exist in the context and scope of games - if a user
// plays two games, he's represented by two distinct players.
type Player struct {
	Id UserId
	State PlayerState
	Murderer UserId
	Victim UserId
	WasOutsmarted bool
	Deaths []Death
	Kills int
}
type PlayerState = int
const (
	PlayerIdle = PlayerState(iota)
	PlayerWaiting = PlayerState(iota)
	PlayerAlive = PlayerState(iota)
	PlayerDying = PlayerState(iota)
	PlayerDead = PlayerState(iota)
)

// A structure that contains information about a player's death. Owned by the
// victim.
type Death struct {
	Time time.Time
	Murderer UserId
	Weapon string
	LastWords string
}

// A structure that holds information about the game in general.
type GameCode = string
type GameState = int
const (
	GameNotStartedYet = GameState(iota)
	GameRunning = GameState(iota)
	GamePaused = GameState(iota)
	GameOver = GameState(iota)
)
type Game struct {
	Code GameCode
	Name string
	State GameState
	Creator UserId
	Created time.Time
	End time.Time
}
