/**
* @file Manual-Communication API.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

/// @function nw_send(eventName, data)
/// @description Sends an event with a struct to the server socket.
///	@param {string} eventName - Name that identifies the event.
///	@param {struct} data - Struct to send.
///	@return {boolean} True 
function nw_send(eventName, data) {
	nw_send_to(nw_get_socket(), eventName, data);
	return true;
}

/// @function nw_send_to(socket, eventName, data)
/// @description Sends an event with a struct to a socket.
///	@param {real} socket - Socket identifier.
///	@param {string} eventName - Name that identifies the event.
///	@param {struct} data - Struct to send.
///	@return {boolean} True 
function nw_send_to(socket, eventName, data) {
	assert_is_not_undefined(socket);
	assert_is_string(eventName, "nw_send_to: invalid parameter 'eventName'");
	global.nwNetworkManager.nwSend(socket, eventName, data);
	return true;
}

/// @function nw_custom_send_to(socket, eventName, data)
/// @description Sends an event with a struct to a socket.
///	@param {real} socket - Socket identifier.
///	@param {string} eventName - Name that identifies the event.
///	@param {struct} data - Struct to send.
///	@return {boolean} True 
function nw_custom_send_to(socket, eventName, data) {
	assert_is_not_undefined(socket);
	assert_is_string(eventName, "nw_custom_send_to: invalid parameter 'eventName'");
	global.nwNetworkManager.nwCustomSend(socket, eventName, data);
	return true;
}

/// @function nw_broadcast(socket, eventName, data)
/// @description Sends an event with a struct to all connected sockets. This can run only in server mode.
///	@param {string} eventName - Name that identifies the event.
///	@param {struct} data - Struct to send.
///	@return {boolean} True 
function nw_broadcast(eventName, data) {
	assert_is_string(eventName, "nw_broadcast: invalid parameter 'eventName'");
	assert_is_true(nw_is_server());
	global.nwNetworkManager.nwSendBroadcast(eventName, data);
	return true;
}

/// @function nw_broadcast_exclude(eventName, data, socket)
/// @description Sends an event with a struct to all connected sockets. This can run only in server mode.
///	@param {string} eventName - Name that identifies the event.
///	@param {struct} data - Struct to send.
///	@param {array} exclude - List of sockets to exclude.
///	@return {boolean} True 
function nw_broadcast_exclude(eventName, data, exclude) {
	assert_is_string(eventName, "nw_broadcast_exclude: invalid parameter 'eventName'");
	assert_is_true(nw_is_server());
	global.nwNetworkManager.nwSendBroadcastExclude(eventName, data, exclude);
	return true;
}

/// @function nw_subscribe_receive(eventName, eventCallback, _args)
///	@description Register a new handler for the given event.
///	@param {string} eventName - Name that identifies the event.
///	@param {function} eventCallback - Function called then the message is received.
///	@param {*} _args - Extra information included in the callback.
///	@return {real} Subscription identifier. 
function nw_subscribe_receive(eventName, eventCallback, _args) {
	assert_is_string(eventName, "nw_subscribe_receive: invalid parameter 'eventName'");
	var sid = global.nwNetworkManager.evSubscribe("recv-" + eventName, eventCallback, _args);
	return sid;
}
