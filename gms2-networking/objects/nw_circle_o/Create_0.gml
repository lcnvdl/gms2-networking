color = c_white;

if (nw_is_server()) {
	var _uuid = nw_add_sender(id, undefined);
	var sender = nw_get_sender(_uuid);
	
	color = choose(c_red, c_blue, c_aqua, c_green, c_lime, c_orange);
	
	sender.AddSyncVarInt("color", 0);
	
	direction = irandom(360);
	speed = 5;
}