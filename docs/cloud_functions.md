# Cloud Functions

The cloud functions wrap the functionality described in ["A murderous graph"](murderous_graph.md) in a webhook and also do administrative stuff like authenticating the caller and sending out notifications (see ["Firebase Cloud Messaging"](cloud_messaging.md)).

## `create_user`

Creates a new user by saving the auth token, the messaging token and the name.
TODO: Validate auth token.

```url
create_user?name=Marcel&authToken=...&messagingToken=...
{
  id: "abcd"
}
```

## `create_game`

Creates a new game with the provided parameters.
The user who calls this method becomes the creator.

```url
create_game?user=...&authToken=...&name=TheGameName&start=12345678&end=123456789
{
  code: "abcd"
}
```

## `join_game`

Joins the user to an existing game.

```url
join_game?user=...&authToken=...&code=abcd
Joined.
```

## `get_game`

TODO: implement properly

```url
get_game?code=abcd
{
  "name": "Spiel",
  "state": 1,
  "created": 1553701496275,
  "creator": "aaa",
  "end": 0,
  "players": [
    {
      "id": "1KD",
      "name": "Marcel Garus",
      "state": 1,
      "murderer": null,
      "victim": "bbb",
      "kills": 0,
      "wantsNewVictim": true,
      "death": null
    },
    {
      "id": "bbb",
      "name": "B",
      "state": 1,
      "kills": 0,
      "death": null
    },
    {
      "id": "ccc",
      "name": "C",
      "state": 1,
      "kills": 0,
      "death": null
    },
    {
      "id": "ddd",
      "name": "D",
      "state": 1,
      "kills": 0,
      "death": null
    }
  ]
}
```

## `start_game`

Starts an existing game.
Only the creator can successfully call this webhook.

```url
start_game?authToken=...&code=abcd
> Game started.
```

## `kill_player`

Kills the caller's victim.
Only useful if the caller has a victim.

```url
kill_player?user=...&authToken=...&code=abcd&id=a0
> Kill request sent to victim.
```

## `die`

The caller confirms the own death.

```url
die?user=...&authToken=...&code=abcd
> You died.
```

## `impeach_death`

## `kick_player`

## `complain_about_being_outsmarted`

## `shuffle_victims`

Shuffle's the players victims.
TODO: implement properly

```url
shuffle_victims?authToken=...&code=...&onlyOutsmartedPlayers=true
> Players shuffled.
```

## `resurrect_players`

## `set_end`
