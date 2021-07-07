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
	
	// var rpcOpts = { allowance: RpcFunctionCallerAllowance.Sender, executors: [RpcFunctionCallerAllowance.Sender] };
	var rpcOpts = { isOwner: true };
	nw_rpc_instance_register_function(id, "getServerInfo", rpcGetServerInfo, rpcOpts);
}
else {
	nw_singleton_receiver(id, "rpc_example");
	
	//	Allow Receiver to call the RPC function
	var rpcOpts = { allowance: RpcFunctionCallerAllowance.Receiver, executors: [RpcFunctionCallerAllowance.Sender] };
	nw_rpc_instance_register_function(id, "getServerInfo", undefined, rpcOpts);
}

getServerInfo = function() {
	nw_rpc_instance_call_function(id, "getServerInfo", {}, function(response) {
		if (!is_undefined(response) && response.isValid) {
			var data = response.data;
			rpc_example_o.currentOsVersion = data;
		}
	});
};