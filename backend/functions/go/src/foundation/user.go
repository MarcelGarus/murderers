package foundation

// UserID is a string that uniquely identifies a user globally or a player in a
// game.
type UserID = string

// User represents a user of the service.
type User struct {
	ID             UserID
	AuthToken      string
	MessagingToken string
	Name           string
}
