/**
* @file RPC API.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

/// @function nw_rpc_initialize()
/// @description Enables RPC on an instance.
function nw_rpc_initialize() {
	global.nwNetworkManager.rpcInitialize(id);
}

/// @function nw_rpc_register(fnName, fnCallback)
/// @param {string} fnName - Function name.
/// @param {function} fnCallback - Function callback. The callback will be called with three optional arguments (result, isValid, response).
/// @description Registers a new RPC function on the RPC Controller of the instance.
function nw_rpc_register(fnName, fnCallback) {
	global.nwNetworkManager.rpcRegisterFunction(id, fnName, fnCallback);
}

/// @function nw_rpc_set_security(fnName, settings)
/// @param {string} fnName - Function name.
/// @param {*} settings - Settings.
function nw_rpc_set_security(fnName, settings) {
	//	TODO	RPC Security
}

/// @function nw_rpc_sender_broadcast(fnName, fnArgs, fnCallback)
/// @param {string} fnName - Function name.
/// @param {*} fnArgs - Arguments for the call. It must be a struct.
/// @param {function} fnCallback - Function callback. The callback will be called without arguments.
/// @description The Sender broadcasts calling each Receiver's function. It won't expect an answer, but an ACK.
function nw_rpc_sender_broadcast(fnName, fnArgs, fnCallback) {
	global.nwNetworkManager.rpcSenderBroadcast(id, fnName, fnArgs, fnCallback);
}

/// @function nw_rpc_self_call(fnName, fnArgs, fnCallback)
/// @param {string} fnName - Function name.
/// @param {*} fnArgs - Arguments for the call. It must be a struct.
/// @param {function} fnCallback - Function callback. The callback will be called with three optional arguments (result, isValid, response).
/// @description The entity calls its own Rpc Function.
function nw_rpc_self_call(fnName, fnArgs, fnCallback) {
	global.nwNetworkManager.rpcSelfCall(id, fnName, fnArgs, fnCallback);
}

/// @function nw_rpc_sender_call(fnName, fnArgs, fnCallback)
/// @param {string} fnName - Function name.
/// @param {*} fnArgs - Arguments for the call. It must be a struct.
/// @param {function} fnCallback - Function callback. The callback will be called with three optional arguments (result, isValid, response).
/// @description The Sender (client-side only) calls to the Receiver's function (server-side only), in order to receive an answer.
function nw_rpc_sender_call(fnName, fnArgs, fnCallback) {
	global.nwNetworkManager.rpcSenderCall(id, fnName, fnArgs, fnCallback);
}

/// @function nw_rpc_receiver_call(fnName, fnArgs, fnCallback)
/// @param {string} fnName - Function name.
/// @param {*} fnArgs - Arguments for the call. It must be a struct.
/// @param {function} fnCallback - Function callback. The callback will be called with three optional arguments (result, isValid, response).
/// @description The Receiver (client or server) calls to the Senders's function (server or client), in order to receive an answer.
function nw_rpc_receiver_call(fnName, fnArgs, fnCallback) {
	global.nwNetworkManager.rpcReceiverCall(id, fnName, fnArgs, fnCallback);
}
