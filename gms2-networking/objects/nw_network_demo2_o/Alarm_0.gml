//	New player per connection
with(global.nwNetworkManager) {
	evSubscribe(EV_CLIENT_CONNECT, function() {
		var inst = instance_create_layer(
			irandom_range(32, room_width - 32),
			irandom_range(32, room_height - 32),
			"Instances",
			nw_player_ship
		);
		
		inst.startAsPlayer();
	}, undefined);
}