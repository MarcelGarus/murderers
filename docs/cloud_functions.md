# Cloud Functions

## `create_user`

Creates a new user by saving the auth token, the messaging token and the name.
TODO: Validate auth token.

```url
create_user?name=Marcel&authToken=...&messagingToken=...
> { id: 'abcd' }
```

## `create_game`

Creates a new game with the provided parameters.
The user who calls this method becomes the creator.

```url
create_game?user=...&authToken=...&name=TheGameName&start=12345678&end=123456789
> { code: 'abcd' }
```

## `join_game`

Joins the user to an existing game.

```url
join_game?user=...&authToken=...&code=abcd
> { id: 'a1b2c3d4e5' }
```

## `get_game`

TODO: implement properly

```url
get_game?code=abcd
> {  }
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
