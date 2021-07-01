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

/// @function nw_set_network_engine_factory(factoryFunction)
/// @description Overrides the Network Manager Factory in order to use a differente Network Engine.
/// @param {function} factoryFunction - Function that returns an instance of Network Engine.
function nw_set_network_engine_factory(factoryFunction) {
	global.nwNetworkManagerFactory = factoryFunction;	
}

/// @function nw_is_server()
/// @description Returns true if it's connected as a server.
/// @return {boolean} Is server?.
function nw_is_server() {
	return global.nwNetworkManager.serverMode;
}

/// @function nw_is_client()
/// @description Returns true if it's connected as a client.
/// @return {boolean} Is client?.
function nw_is_client() {
	return nw_is_online() && !nw_is_server();	
}

/// @function nw_is_online()
/// @description Returns true if it's connected.
/// @return {boolean} Is online / connected?.
function nw_is_online() {
	return !global.nwNetworkManager.offline;
}

/// @function nw_get_socket()
/// @description Returns the server socket.
/// @return {real} Socket index.
function nw_get_socket() {
	return global.nwNetworkManager.serverSocket;
}

/// @function nw_subscribe_connect(callbackFunction, eventArgs)
/// @description Subscribes to the connection event. It is called every time the server receives a new connection.
/// @return {real} Subscription index.
function nw_subscribe_connect(callbackFunction, eventArgs) {
	var sid = global.nwNetworkManager.evSubscribe(EV_SOCKET_CONNECT, callbackFunction, eventArgs);
	return sid;
}

/// @function nw_subscribe_connect(callbackFunction, eventArgs)
/// @description Subscribes to the disconnection event. It is called every time a client disconnects from the server.
/// @return {real} Subscription index.
function nw_subscribe_disconnect(callbackFunction, eventArgs) {
	var sid = global.nwNetworkManager.evSubscribe(EV_SOCKET_DISCONNECT, callbackFunction, eventArgs);
	return sid;
}

/// @function nw_subscription_destroy(subscriptionIndex)
/// @description Removes a subscription.
function nw_subscription_destroy(subscriptionIndex) {
	assert_is_number(subscriptionIndex);
	global.nwNetworkManager.unsubscribe(subscriptionIndex);
}
