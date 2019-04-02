package bloc

import (
	"murderers/context"
	. "murderers/foundation"
)

// CreateUser creates a new user.
func CreateUser(
	c context.Context,
	name string,
	authToken string,
	messagingToken string,
) (*User, RichError) {
	// TODO: Verify that the authToken is a valid Firebase Auth Token.

	// Try to generate a new ID.
	var id UserId
	tries := 0
	for {
		id = UserID(generateRandomString(UserIdCharacters, UserIdLength))
		tries++
		if _, err := s.LoadUser(id); err != nil {
			break // No user with the id exists, so the id is free to take.
		}
		if tries >= UserIdMaxTries {
			return nil, ExceededNumberOfTriesWhileGeneratingIDError()
		}
	}

	// Create a user with that id.
	user := User{
		Id:             id,
		Name:           name,
		AuthToken:      authToken,
		MessagingToken: messagingToken,
	}

	// Save the user.
	if err := c.s.SaveUser(user); err != nil {
		return nil, err
	}

	return user, nil
}
