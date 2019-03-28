package storage

import (
	"models"
)

type UserNotFoundError UserId
func (id UserNotFoundError) Error() string {
	return fmt.Sprintf("storage: user with id %s not found", string(id))
}
func (id UserNotFoundError) Status() int {
	return 404
}

type UserCorruptError UserId
func (id UserCorruptError) Error() string {
	return fmt.Sprintf("storage: user with id %s is corrupt", string(id))
}
func (id UserCorruptError) Status() int {
	return 500
}

type GameNotFoundError GameCode
func (code GameNotFoundError) Error() string {
	return fmt.Sprintf("storage: game with code %s not found", string(code))
}
func (code GameNotFoundError) Status() int {
	return 404
}

type GameCorruptError GameCode
func (code GameCorruptError) Error() string {
	return fmt.Sprintf("storage: game with id %s is corrupt", string(id))
}
func (code GameCorruptError) Status() int {
	return 500
}
