package models

import (
	"time"
)

type GameCode = string
type GameState = int
const (
	GameNotStartedYet = GameState(iota)
	GameRunning = GameState(iota)
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
