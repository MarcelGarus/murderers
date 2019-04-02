package bloc

import (
	"murderers/context"
	. "murderers/foundation"
)

func GetGameAndUser(
	c context.C,
	code GameCode,
	me UserID,
	authToken string,
) (Game, User, RichError) {
	// Load and authenticte the user.
	if me != nil {
		user, err := c.Storage.LoadUser(me)
		if err != nil {
			return nil, nil, err
		}
		if err := c.AuthenticateUser(); err != nil {
			return err
		}
	}

	// Load the game
	game, err := c.Storage.LoadGame(code)
	if err != nil {
		return err
	}

	return game, user, nil
}

/*
	// Load the game.
	const game: Game = await loadGame(res, firestore, code);
	if (game === null) return;

	// Load the user.
	const user: User = await loadAndVerifyUser(firestore, id, authToken, null);
	if (user === null) {
	  id = null;
	  authToken = null;
	}

	// Load the players.
	const players: {id: string, data: Player}[] = await loadPlayersAndIds(
	  res, allPlayersRef(firestore, code).get());
	if (players === null) return;
	console.log("Players are " + JSON.stringify(players));

	// Load the other users.
	const playerUsers = new Map();
	for (const player of players) {
	  if (player.id === id) continue;

	  const playerUser: User = await loadUser(firestore, player.id, res);
	  if (playerUser === null) return;
	  playerUsers[player.id] = playerUser;
	}

	// Send back the game's state.
	res.set('application/json').send({
	  name: game.name,
	  state: game.state,
	  created: game.created,
	  creator: game.creator,
	  end: game.end,
	  players: players.map((playerAndId, _, __) => {
		const playerId: UserId = playerAndId.id;
		const player: Player = playerAndId.data;
		const death: Death = player.death;
		const isMe: boolean = (playerId === id);

		if (isMe) {
		  return {
			id: id,
			name: user.name,
			state: player.state,
			murderer: player.murderer,
			victim: player.victim,
			kills: player.kills,
			wantsNewVictim: player.wantsNewVictim,
			death: death === null ? null : {
			  time: death.time,
			  murderer: death.murderer,
			  weapon: death.weapon,
			  lastWords: death.lastWords
			}
		  };
		} else {
		  return {
			id: playerId,
			name: playerUsers[playerId].name,
			state: player.state,
			kills: player.kills,
			death: death === null ? null : {
			  time: death.time,
			  weapon: death.weapon,
			  lastWords: death.lastWords
			}
		  };
		}
	  })
	});
  }
*/
