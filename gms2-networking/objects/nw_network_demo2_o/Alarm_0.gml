with(global.nwNetworkManager) {
	evSubscribe("client-connect", function() {
		var inst = instance_create_layer(
			irandom_range(32, room_width-32),
			irandom_range(32, room_height-32),
			"Instances",
			nw_client_sender_controlled_by_server_o
		);
		
		inst.isPlayer = true;
	}, undefined);
}