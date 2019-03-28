package models

type UserId = string
type User struct {
	Id UserId
	AuthToken string
	MessagingToken string
	Name string
}
