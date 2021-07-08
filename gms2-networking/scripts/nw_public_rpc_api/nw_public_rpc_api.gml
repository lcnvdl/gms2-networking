/**
* @file RPC API.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_rpc_register(fnName, fnCallback) {
	global.nwNetworkManager.rpcRegisterFunction(id, fnName, fnCallback);
}

function nw_rpc_set_security(fnName, settings) {
}

function nw_rpc_sender_broadcast(fnName, fnArgs, fnCallback) {
	global.nwNetworkManager.rpcSenderBroadcast(id, fnName, fnArgs, fnCallback);
}

function nw_rpc_self_call(fnName, fnArgs, fnCallback) {
	global.nwNetworkManager.rpcSelfCall(id, fnName, fnArgs, fnCallback);
}

function nw_rpc_sender_call(fnName, fnArgs, fnCallback) {
	global.nwNetworkManager.rpcSenderCall(id, fnName, fnArgs, fnCallback);
}

function nw_rpc_receiver_call(fnName, fnArgs, fnCallback) {
}

/// @deprecated
function nw_rpc_instance_register_function(instanceOrUuid, name, fnCall) {	
	var instanceUuid;
	
	if (is_string(instanceOrUuid)) {
		instanceUuid = instanceOrUuid;
	}
	else {
		instanceUuid = instanceOrUuid.nwUuid;
	}

	var _opts = argument_count > 3 ? argument[3] : {};
	
	if(is_undefined(_opts)) {
		_opts = {};	
	}
	
	global.nwNetworkManager.registerInstanceRpcFunction(instanceUuid, name, fnCall, _opts);
}

/// @deprecated
function nw_rpc_instance_call_function(instanceOrUuid, fnName, fnArgs, fnCallback) {
	var instanceUuid;
	
	if (is_string(instanceOrUuid)) {
		instanceUuid = instanceOrUuid;
	}
	else {
		instanceUuid = instanceOrUuid.nwUuid;
	}

	global.nwNetworkManager.callInstanceRpcFunction(instanceUuid, fnName, fnArgs, true, fnCallback);	
}
