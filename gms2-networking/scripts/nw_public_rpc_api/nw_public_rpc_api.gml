/**
* @file RPC API.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_instance_register_function(instance, name, fnCall) {	
	var _opts = argument_count > 3 ? argument[3] : undefined;
	global.nwNetworkManager.registerRpcFunction(instance, name, fnCall, _opts);
}

function nw_call_function(instance, fnName, fnArgs, fnCallback) {
	global.nwNetworkManager.callRpcFunction(instance, fnName, fnArgs, fnCallback);	
}
