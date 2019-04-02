package foundation

// RichError is an error that not only holds a message but also an id as well as
// an http-like status code.
// Used throughout the code so the webhook knows more about what to return to
// the client in case something goes wrong.
type RichError interface {
	ID() int
	Error() string
	Status() int
}

type concreteRichError struct {
	id      int
	message string
	status  int
}

func (e *concreteRichError) ID() int {
	return e.id
}
func (e *concreteRichError) Error() string {
	return e.message
}
func (e *concreteRichError) Status() int {
	return e.status
}

// BadRequestError indicates that the client did something wrong.
func BadRequestError(id int, message string) RichError {
	return &concreteRichError{
		id:      id,
		message: message,
		status:  400,
	}
}

// NoPrivilegesError indicates that the client is not authorized to perform the
// desired action.
func NoPrivilegesError(id int, message string) RichError {
	return &concreteRichError{
		id:      id,
		message: message,
		status:  403,
	}
}

// ResourceNotFoundError indicates that a resource is missing.
func ResourceNotFoundError(id int, message string) RichError {
	return &concreteRichError{
		id:      id,
		message: message,
		status:  404,
	}
}

// InternalServerError indicates that the error is solely the server's fault.
func InternalServerError(id int, message string) RichError {
	return &concreteRichError{
		id:      id,
		message: message,
		status:  500,
	}
}
