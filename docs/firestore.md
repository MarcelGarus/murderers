# Firestore

This document describes how the data state described in [the data model](data_model.md) is mapped into Firestore.

Firestore holds collections and documents.

## Collections

There are two top-level collections:

* `users` which holds all users and
* `games` which holds all the games.

The id of a document in the `users` collection is called the *user's id*.

The id of a document in the `games` collection is called the *game's code*.

Furthermore, each game has a sub-collection with the `players` (each player's id equals the corresponding user's id).

## Documents

### Users

All users (documents in the `users` collection) have the following structure:

```firestore
id {
  authToken: string,
  messagingToken: string,
  name: string
}
```

### Games

All games (documents in the `games` collection) have the following structure:

```firestore
code {
  name: string,
  created: string,
  creator: string,
  state: int,
  end: datetime,
}
```

where the state is encoded as:

```firestore
0: game didn't start yet
1: game is running
2: game over
```

Also, games may have a sub-collection called `players`.

### Players

All players (documents in a `players` collection) have the following structure:

```firestore
id {
  state: int,
  kills: int,
  murderer: string?,
  victim: string?,
  isOutsmarted: bool,
  death: {
    murderer: string,
    time: datetime,
    lastWords: string,
    weapon: string
  }?
}
(a ? indicates that the value may be null)
```

The state is encoded as:

```firestore
0: player is joining
1: player is waiting to be assigned to a victim
2: player is alive (and on the hunt)
3: player is dying
4: player is dead
```
