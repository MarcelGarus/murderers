package bloc

import (
	"fmt"
	"math/rand"
	. "murderers/foundation"
)

func generateRandomString(chars string, length int) string {
	runes := []rune(chars)
	s := ""

	for len(s) < length {
		s += fmt.Sprintf("%c", runes[rand.Intn(len(chars))])
	}
	return s
}

func loadAndAuthenticateUser(id UserID, authToken string) (User, RichError) {
	var user User

	if user, err = f.s.LoadUser(myId); err != nil {
		return nil, err
	} else if ok = validateUser(user, authToken); !ok {
		return nil, AuthenticationFailedError()
	}

	return user, nil
}
