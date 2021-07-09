currentOsVersion = undefined; 

if(nw_is_server()) {
	//	Sender
	var sender = nw_add_empty_sender(id, "rpc_example");
	
	//	RPC for Receiver Call
	var rpcGetServerInfo = function() {
		return {
			osType: os_type,
			osVersion: os_version,
			region: os_get_region(),
			now: date_current_datetime()
		};
	};
	
	nw_rpc_register("getServerInfo", rpcGetServerInfo);
	
	//	Broadcast Call
	sendBroadcast = function() {
		nw_rpc_sender_broadcast("showMessage", { msg: "Hello world!" }, function() {
			show_debug_message("Broadcast sent");	
		});
	};
}
else {
	//	Receiver
	nw_singleton_receiver(id, "rpc_example");
	
	//	RPC for broadcast
	nw_rpc_register("showMessage", function(args) {
		show_message(args.msg);
	});
}

getServerInfoCallback = function(response) {
	if (!is_undefined(response) && response.isValid) {
		var data = response.data;
		rpc_example_o.currentOsVersion = data;
	}
};

//	Receiver call (or self-call if it's called from the server)
getServerInfo = function() {
	if(nw_is_server()) {
		nw_rpc_self_call("getServerInfo", {}, getServerInfoCallback);
	}
	else {
		nw_rpc_receiver_call("getServerInfo", {}, getServerInfoCallback);
	}
};