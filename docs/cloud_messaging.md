# Firebase Cloud Messaging

Firebase Cloud Messaging is used for delivering notifications to users.

## App behavior

If the app is in the background, a notification is displayed on the user's device.
Tapping on it causes the app to open and reload the game.

If the app is in the foreground, it simply reloads the game.

## Notifications

In FCM, you can send notifications to *topics*, which clients can subscribe to.
Alternatively, notifications can be sent to individual devices using their FCM token.
These are all the notifications sent by the server over the course of a game:

* **Someone attempts to join the game**: sent to the creator (using the FCM token).
* **Someone joined a game**: sent to all clients that subscribed to both topics `game_<code>` and `player_joined`.
* **A game started**: sent to topic `game_<code>`.
* **A game ended**: sent to topic `game_<code>`.
* **You got murdered**: sent to the victim (using the FCM token).
* **Your victim confirmed its death**: sent to the murderer (using the FCM token).
* **A death occurred**: sent to all clients that subscribed to both `game_<code>` and `deaths`.

All in-game notifications share the same Android collapse key `game_<code>` so that they will be collapsible in the notification area.

Notifications that are meta-game notifications targeted only to the admin (like new players who want to join), share the Android collapsible key `game_<code>_admin`, so the admin has one group of in-game notifications and one of administrative ones.
