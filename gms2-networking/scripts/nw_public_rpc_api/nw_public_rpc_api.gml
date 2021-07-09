/**
* @file RPC API.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_rpc_initialize() {
	global.nwNetworkManager.rpcInitialize(id);
}

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
	global.nwNetworkManager.rpcReceiverCall(id, fnName, fnArgs, fnCallback);
}
