color = c_white;
hp = 100;
isPlayer = false;
myUuid = "";

function startAsPlayer() {
	if (nw_is_client()) {
		var _uuid = nw_add_sender(id, undefined);
		var sender = nw_get_sender(_uuid);
	
		isPlayer = true;
		color = choose(c_red, c_blue, c_aqua, c_green, c_lime, c_orange);
	
		sender.AddSyncVarInt("hp", 100).SetBinding(SyncVarBinding.Server);
		sender.AddSyncVarInt("color", 0);
		
		myUuid = _uuid;
	}
}

//	Server behaviour
if (nw_is_server()) {
	//	Register server variables
	nwOnCreateReceiver = function(_receiver) {
		_receiver.AddSyncVarInt("hp", 100).SetBinding(SyncVarBinding.Server);
	};
	
	//	Change the HP randomly
	alarm[0] = room_speed;
}
