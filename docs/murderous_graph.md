# A murderous graph

A main concern of the game is to keep track of who has to kill whom.
We can construct a murderous graph, where the nodes are players and directed edges indicate who's supposed to kill whom.
This document describes how the in-game operations (starting a game, killing players etc.) work on the graph.

## Starting a game

The moment the game starts, the task is to connect the nodes.
Currently, they are all unconnected.

We could just connect them randomly and make sure that no node points to itself.
However, according to experience the game is less fun if there are multiple cycles. For example, if A's victim is B and B's victim is A, after one of them killed the other they can no longer participate in the game.

To counter this issue, the only way is to connect all players to one big cycle.
The order of the players is selected randomly.

![start](images/murderous_graph_start.svg)

**Insight: The murderous graph should always be one big cycle.**

## Shuffling players who want a new victim

Some players may behave awkward around their victim and make it obvious to it that they are their murderer.
That's why they can request a new victim.

To give them new victims, we'll first have to split the graph into multiple graphs by deleting every connection after the players who requested new victims.
Then, our task is to put the graph back together.

### One player wants a new victim

If only one player requests a new victim, there's not much we can do.
If we split up the graph, there's only one option to put it back together:
The graph we started with.

![murderous graph where one player wants a new victim](images/murderous_graph_new_victim_1.svg)

### Two players want new victims

If two players request a new victim, there's no luck either.
If we split up the graph, we can only achieve one of these results:

* The graph we started it.
* A graph with two cycles, which we don't want for the reasons above (see "Starting a game").

![murderous graph where two players want new victims](images/murderous_graph_new_victim_2.svg)

### Three or more players want new victims

Finally!
This is where things get interesting.
After splitting up the graph, we can reverse the order in which the sub-graphs are connected, thereby making sure that every murderer who wanted a new victim gets one.

![murderous graph where three players want new victims](images/murderous_graph_new_victim_3.svg)

Obviously, this also works with more than three players.

## Joining a running game

If players join a running game, they need to be inserted into the graph.
If there's someone who wants a new victim, we can simply insert the new player between that someone and its victim.
If there's no one who wants a new victim, we'll have to wait until the next murder occurs and then insert the new player between the murderer and its next victim.

## Killing a player

If a player gets killed, the victim's victim becomes the new victim of the murderer.

If some players are waiting for a victim, they are randomly inserted between the murderer and the victim's victim.

If there are two players who want another victim, the murderer is first given the new victim. Then he's treated as if he wanted a new victim.
That makes it possible to apply the rule described above in "Three or more players want new victims".
