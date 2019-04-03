package bloc

import (
	"murderers/context"
	. "murderers/foundation"
)

// CreateUser creates a new user.
func CreateUser(
	c *context.C,
	name string,
	authToken string,
	messagingToken string,
) (*User, RichError) {
	// TODO: Verify that the authToken is a valid Firebase Auth Token.
	// TODO: Verify that a user with that authToken doesn't exist yet.

	// Try to generate a new ID.
	var id UserID
	tries := 0
	for {
		id = UserID(generateRandomString(UserIDCharacters, UserIDLength))
		tries++
		if _, err := c.LoadUser(id); err != nil {
			break // No user with the id exists, so the id is free to take.
		}
		if tries >= UserIDMaxTries {
			return nil, ExceededNumberOfTriesWhileGeneratingIDError()
		}
	}

	// Create a user with that id.
	user := User{
		ID:             id,
		Name:           name,
		FirebaseID:     authToken,
		MessagingToken: messagingToken,
	}

	// Save the user.
	if err := c.SaveUser(user); err != nil {
		return nil, err
	}

	return &user, nil
}
