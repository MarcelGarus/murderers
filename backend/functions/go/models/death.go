package models

import (
	"time"
)

type Death struct {
	Time time.Time
	Murderer UserId
	Weapon string
	LastWords string
}
