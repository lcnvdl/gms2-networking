global.globalScore += irandom_range(1, 10);

randomize();

var players = ["SOL", "LOS", "ABC", "REN", "KEN", "LUC", "CLR"];
var player = players[irandom(array_length(players) -1)];
var newScore = irandom(999);

global.highscoreTable[$ player] = newScore;

alarm[0] = room_speed;