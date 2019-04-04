package bloc

import (
	"fmt"
	"math/rand"
)

func generateRandomString(chars string, length int) string {
	runes := []rune(chars)
	s := ""

	for len(s) < length {
		s += fmt.Sprintf("%c", runes[rand.Intn(len(chars))])
	}
	return s
}
