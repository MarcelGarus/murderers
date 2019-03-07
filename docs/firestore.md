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

### Games

### Players

The data model equals the one described above, with the exception of user ids and game codes.
Those aren't explicitly saved, because they are represented by Firestore's document id.

The collection `games` holds all the games as documents.
The games' codes equal the documents' ids.
Each game holds information about the game itself, just like described in the data model.

Also, each game has a sub-collection of `players`.
The players' ids equal the corresponding documents' ids.
Each player holds information about him/herself, just like described in the data model.
