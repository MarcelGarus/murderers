package context

import . "murderers/foundation"

// ReservedForCreatorError indicates that a non-creator attempted to execute an
// action that only the creator is able to execute.
func ReservedForCreatorError() RichError {
	return NoPrivilegesError(21, "Only the creator can execute this action.")
}
