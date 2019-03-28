package utils

type ErrorWithStatus struct {
	status int
	message string
}
func (ews ErrorWithStatus) Status() int {
	return ews.status
}
func (ews ErrorWithStatus) Error() string {
	return ews.message
}

func BadRequestError(message string) ErrorWithStatus {
	return ErrorWithStatus{
		status: 400,
		message: message,
	}
}

func NoPrivilegesError(message string) ErrorWithStatus {
	return ErrorWithStatus{
		status: 403,
		message: message,
	}
}

func ResourceNotFoundError(message string) ErrorWithStatus {
	return ErrorWithStatus{
		status: 404,
		message: message,
	}
}

func InternalServerError(message string) ErrorWithStatus {
	return ErrorWithStatus{
		status: 500,
		message: message,
	}
}

func GameAlreadyOverError() ErrorWithStatus {
	return BadRequestError("The game is already over.")
}
func AuthenticationFailedError() ErrorWithStatus {
	return NoPrivilegesError("Authentication failed.")
}
func ReservedForCreatorError() ErrorWithStatus {
	return NoPrivilegesError("Only the creator can execute this action.")
}
