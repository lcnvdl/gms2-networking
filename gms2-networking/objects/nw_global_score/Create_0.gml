global.globalScore = 0;

//	Server behaviour
if (nw_is_server()) {
	var _uuid = nw_add_sender(id, undefined);
	var sender = nw_get_sender(_uuid);
	
	sender.AddSyncVarInt("global.globalScore", 0);
	
	alarm[0] = room_speed;
}
