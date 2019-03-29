func GameAlreadyOverError() RichError {
	return BadRequestError("The game is already over.")
}
func AuthenticationFailedError() RichError {
	return NoPrivilegesError("Authentication failed.")
}
func ReservedForCreatorError() RichError {
	return NoPrivilegesError("Only the creator can execute this action.")
}
func VictimNotDyingError() RichError {
	return BadRequestError("The victim isn't dying.")
}
