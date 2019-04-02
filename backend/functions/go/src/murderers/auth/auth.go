package auth

import . "murderers/foundation"

// AuthenticateClient authenticates the user with the given firebaseID with the
func AuthenticateClient(firebaseID string, authToken string) RichError {
	if firebaseID == authToken {
		return nil
	}
	return AuthenticationFailedError()
}
