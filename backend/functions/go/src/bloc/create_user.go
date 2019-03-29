package bloc

import (
	"errors"
)

func generateUniqueUserId(s Storage) (UserId, ErrorWithStatus) {
	var id UserId
	tries := 0

	loop: for {
		id = UserId(generateRandomString(UserIdCharacters, UserIdLength))
		tries++

		if _, err := s.LoadUser(id); err != nil {
			// No user with the id exists, so the id is free to take.
			break loop
		}

		if tries >= UserIdMaxTries {
			return "", InternalServerError("Exceeded maximum number of tries while generating a user id.")
		}
	}

	return id, nil
}

func CreateUser(s Storage, name string, authToken string, messagingToken string) (User, ErrorWithStatus) {
	var user User
	id, err := generateUniqueUserId(s)

	if err != nil {
		return user, err
	}

	user = User{
		Id: id,
		Name: name,
		AuthToken: authToken,
		MessagingToken: messagingToken,
	}

	if user, err = s.SaveUser(user); err != nil {
		return user, err
	}

	return user, nil
}
