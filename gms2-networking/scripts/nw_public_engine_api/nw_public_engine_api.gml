/**
* @file Networking Engine API.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

/// @function nw_configure(ip, port)
/// @param {string} ip - Server IP.
/// @param {real} port - Server Port.
/// @description Sets up the connection address.
function nw_configure(ip, port) {
	nwEnsureEngine();
	
	assert_is_true(global.nwNetworkManager.offline, "The game already has an open connection.");
	assert_is_string(ip);
	assert_is_number(port);
	
	global.nwNetworkManager.networkSettings.ip = ip;
	global.nwNetworkManager.networkSettings.port = port;
}

/// @function nw_start_client()
/// @description Starts the systen in client mode, connecting it to the server.
/// @return {Socket} Client socket.
function nw_start_client() {
	nwEnsureEngine();
	return global.nwNetworkManager.startClient();	
}

/// @function nw_start_server()
/// @description Starts the system in server mode.
/// @return {Socket} Server socket.
function nw_start_server() {
	nwEnsureEngine();
	return global.nwNetworkManager.startServer();	
}

function nw_set_network_engine_factory(_function) {
	global.nwNetworkManagerFactory = _function;	
}

function nw_is_server() {
	return global.nwNetworkManager.serverMode;
}

function nw_is_client() {
	return nw_is_online() && !nw_is_server();	
}

function nw_is_online() {
	return !global.nwNetworkManager.offline;
}

function nw_get_socket() {
	return global.nwNetworkManager.serverSocket;
}

function nw_subscribe_connect(_fn, _args) {
	var sid = global.nwNetworkManager.evSubscribe(EV_SOCKET_CONNECT, _fn, _args);
	return sid;
}

function nw_subscribe_disconnect(_fn, _args) {
	var sid = global.nwNetworkManager.evSubscribe(EV_SOCKET_DISCONNECT, _fn, _args);
	return sid;
}

function nw_subscription_destroy(_subscription) {
	assert_is_number(_subscription);
	global.nwNetworkManager.unsubscribe(_subscription);
}
