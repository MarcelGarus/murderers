package foundation

import "fmt"

// UserID is a string that uniquely identifies a user globally or a player in a
// game.
type UserID = string

// User represents a user of the service.
type User struct {
	ID             UserID
	FirebaseID     string
	MessagingToken string
	Name           string
}

func (u User) String() string {
	return fmt.Sprintf("{User %s, %s}", u.ID, u.Name)
}
