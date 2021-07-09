counter = 0;
color = c_white;
isLoading = false;
isPlayer = false;

nw_rpc_initialize();

if(nw_is_client()) {
	startAsPlayer = function() {
		var _uuid = nw_add_sender(id, undefined);
		var sender = nw_get_sender(_uuid);
	
		randomize();
	
		sender.AddSyncVarInt("color", 0);
	
		color = choose(c_red, c_blue, c_green, c_yellow, c_purple, c_white, c_aqua);
		x = irandom(room_width);
		y = room_height*2 / 3;
		
		isPlayer = true;
	}
}

if(nw_is_server()) {
	nwOnCreateReceiver = function(newReceiver) {
		//	RPC for broadcast
		nw_rpc_register("increaseCounter", function(args) {
			counter += args.increment;
			return counter;
		});	
	}
}

increaseCounterCallback = function(response) {
	if (response.isValid) {
		counter = response.data;	
	}
	isLoading = false;
};

//	Receiver call (or self-call if it's called from the server)
increaseCounter = function(increment) {
	if(nw_is_server()) {
		//	We want this to only be called by clients
		// nw_rpc_self_call("increaseCounter", {}, increaseCounterCallback);
	}
	else {
		if (!isLoading) {
			isLoading = true;
			nw_rpc_sender_call("increaseCounter", { increment: increment }, increaseCounterCallback);
		}
	}
};