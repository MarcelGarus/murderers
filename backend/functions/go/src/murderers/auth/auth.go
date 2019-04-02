package auth

import . "murderers/foundation"

// AuthenticateClient authenticates the user with the given firebaseID with the
// given authToken. Returns an error if the authentication failed.
func AuthenticateClient(firebaseID string, authToken string) RichError {
	if firebaseID == authToken {
		return nil
	}
	return AuthenticationFailedError()
}
