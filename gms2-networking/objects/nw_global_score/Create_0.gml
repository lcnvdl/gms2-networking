global.globalScore = 0;
global.highscoreTable = {};

//	Server behaviour
if (nw_is_server()) {
	var _uuid = nw_add_empty_sender(id, undefined);
	var sender = nw_get_sender(_uuid);
	
	sender.AddSyncVarInt("global.globalScore", 0);
	sender.AddSyncVarStruct("global.highscoreTable");
	
	alarm[0] = room_speed;
}
