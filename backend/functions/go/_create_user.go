package main

import (
	"errors"
)

func generateUniqueUserId(s Storage) (UserId, error) {
	var id UserId
	tries := 0

	loop: for {
		id = UserId(generateRandomString(UserIdCharacters, UserIdLength))
		tries++

		if _, err := s.LoadUser(id); err != nil {
			if serr, ok := err.(*UserNotFoundError); ok {
				// The user couldn't be found, so the id is free to take.
				break loop
			} else {
				return "", serr
			}
		}
		
		if tries >= UserIdMaxTries {
			return "", errors.New("create_user: Exceeded maximum number of tries while generating a user id.")
		}
	}

	return id, nil
}

func CreateUser(s Storage, name string, authToken string, messagingToken string) (User, error) {
	var user User
	id, err := generateUniqueUserId(s)

	if err != nil {
		return user, error
	}

	user = User{
		Id: id,
		Name: name,
		AuthToken: authToken,
		MessagingToken: messagingToken,
	}

	if user, err = s.SaveUser(user); err != nil {
		fmt.Println("create_user: Couldn't save user.")
		return user, nil
	}

	return user, nil
}
