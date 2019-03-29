class Player:
    def __init__(self, name):
        self.name = name
        self.victim = None
        self.wantsNewVictim = False
    def __str__(self):
        return f"{self.name}({self.victim.name})"
    def __repr__(self):
        return f"{self.name}({self.victim.name})"

def createPlayers(size: int):
  players = []
  for i in range(size):
    players.append(Player(chr(ord("A")+i)))
    if len(players) > 1:
      players[-2].victim = players[-1]
  players[-1].victim = players[0]
  return players

def satisfyPlayers(players):
  splitted = []
  start = None
  for player in players:
    if start == None:
      start = player
    if player.wantsNewVictim:
      splitted.append((start, player))
      start = None
  if not (splitted[-1][1].wantsNewVictim):
    splitted[0] = (player, splitted[0][1])
  print(splitted)
  for i in range(len(splitted)):
    splitted[i][1].victim = splitted[i-1][0] if i > 0 else splitted[-1][0]
  print(splitted)

players = createPlayers(6)
a, b, c, d, e, f = players
b.wantsNewVictim = True
e.wantsNewVictim = True
f.wantsNewVictim = True
print(f"Players are {players}")
satisfyPlayers(players)
print(f"Players are {players}")
