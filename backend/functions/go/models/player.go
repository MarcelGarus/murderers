package models

type Player struct {
	Id UserId
	Code GameCode
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
