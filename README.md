# Murderers

A dead-simple multi-player real-world game lasting several days.

Interested in how everything works under the hood?
Read the ["Getting started"](docs/getting_started.md) guide!

## How it works: The basics

First, a **user** *creates* a game. He's called the **creator** of the game and receives a **game code** that uniquely identifies the game among all games.

By sharing this code with other users, he can allow them to *join*.
Users who joined a game are called **players**.
The creator himself can also join the game.
Once enough players joined, the creator can *start* the game.

Every player gets a **victim**, another player which he's supposed to kill.
*Killing* refers to handing over an object in the real world and then logging the event in the app.
The victim will then receive an alert that it has been killed, which it can either *confirm* or *appeal*.
The victim *dies* by confirming.
If the victim *appeals*, the murderer and the creator get notified.

Each game runs for a set amount of time.
Once the game is over, all players get notified.
During the game, there's a scoreboard that shows who killed how many players.
The **winner** is whoever killed the most people.

## Extended functionality

### Joining mid-game

If players join mid-game, they are added to a set of players who want a new victim.
Each time an active player dies, all of these players get added between the murderer and the victim's victim.

### Leaving mid-game

If players leave a game, it's just like they die.

### Complaining

If victims know their murderer, the game is not much fun anymore.
That's why murderers can complain about that.
Once enough people complained, the creator can shuffle them, mixing up the situation.

### Shuffling players

The creator can shuffle players, causing all victims to be selected randomly.

### Resurrecting players

The creator can resurrect players, joining them to the set of players who want to play.

## Interesting aspects of the game (from a programmer's point of view)

* It's a fun, social game.
* It's highly asynchronous (many independent actors).
* It's all about information management.
