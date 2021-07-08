currentOsVersion = undefined; 

if(nw_is_server()) {
	var sender = nw_add_empty_sender(id, "rpc_example");
	
	var rpcGetServerInfo = function() {
		return {
			osType: os_type,
			osVersion: os_version,
			region: os_get_region(),
			now: date_current_datetime()
		};
	};
	
	nw_rpc_register("getServerInfo", rpcGetServerInfo);
	
	sendBroadcast = function() {
		nw_rpc_sender_broadcast("showMessage", { msg: "Hello world!" }, function() {
			show_debug_message("Broadcast sent");	
		});
	};
}
else {
	nw_singleton_receiver(id, "rpc_example");
	
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

getServerInfo = function() {
	if(nw_is_server()) {
		nw_rpc_self_call("getServerInfo", {}, getServerInfoCallback);
	}
	else {
		nw_rpc_receiver_call("getServerInfo", {}, getServerInfoCallback);
	}
};