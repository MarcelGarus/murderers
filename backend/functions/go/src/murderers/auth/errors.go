package auth

import . "murderers/foundation"

// AuthenticationFailedError indicates that the user is not authenticated.
func AuthenticationFailedError() RichError {
	return NoPrivilegesError(11, "Authentication failed.")
}
