/// @function nw_configure(ip, port)
/// @param {string} ip - Server IP.
/// @param {real} port - Server Port.
/// @description Sets up the connection address.
function nw_configure(ip, port) {
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
	return global.nwNetworkManager.startClient();	
}

/// @function nw_start_server()
/// @description Starts the system in server mode.
/// @return {Socket} Server socket.
function nw_start_server() {
	return global.nwNetworkManager.startServer();	
}

/// @function nw_add_sender(instance, _uuid, *opts)
/// @description 	Registers a game object as a Sender. A Sender it's an instance 
///								responsible to replicate its values to the Receivers. 
///								When a Sender is created, the system creates a Receiver 
///								instance in each network node. The Receivers receive
///								information from the senders, like the Position (x, y), the
///								image_angle, etc.  You can add more synchronization variables.
///								Default synchronized variables: 
///									x, y, image_alpha, image_angle, image_single
/// @param {instance} instance - Instance ID.
/// @param {string|undefined} _uuid - UUID (string). If it's undefined, an unique UUID is automatically generated.
/// @param {*} [opts] - Custom settings.
/// @return {string} Final UUID.
function nw_add_sender(instance, _uuid) {
	return global.nwNetworkManager.nwRegisterObjectAsSyncSender(instance, _uuid, argument_count > 2 ? argument[2] : undefined);
}

/// @function nw_add_empty_sender(instance, _uuid)
/// @description 	Registers a game object as a Sender. The empty sender has no 
///								synchronization variables by default. You can add more 
///								synchronized values.
/// @param {instance} instance - Instance ID.
/// @param {string|undefined} _uuid - UUID (string). If it's undefined, an unique UUID is automatically generated.
/// @return {string} Final UUID.
function nw_add_empty_sender(instance, _uuid) {
	var _opts = { 
		emptySender: true 
	};
	return global.nwNetworkManager.nwRegisterObjectAsSyncSender(instance, _uuid, _opts);
}

function nw_singleton_receiver(instance, _uuid) {
	assert_is_string(_uuid);
	instance.nwUuid = _uuid;
}

function nw_server_register_validator(objectIndex, fn) {
	global.nwNetworkManager.getServerController().RegisterValidator(objectIndex, fn);
}

function nw_server_unregister_validator(objectIndex) {
	global.nwNetworkManager.getServerController().UnregisterValidator(objectIndex);
}

function nw_server_clear_validators() {
	global.nwNetworkManager.getServerController().ClearValidators();
}

function nw_get_senders_mgr() {
	return global.nwNetworkManager.getSendersManager();	
}

function nw_get_sender(_uuid) {
	return global.nwNetworkManager.getSendersManager().Get(_uuid);
}

function nw_instance_register_function(instance, name, fnCall) {
	var _opts = argument_count > 3 ? argument[3] : undefined;
	global.nwNetworkManager.registerRpcFunction(instance, name, fnCall, _opts);
}

function nw_call_function(instance, fnName, fnArgs) {
	global.nwNetworkManager.callRpcFunction(instance, fnName, fnArgs);	
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

function nw_send(_name, _data) {
	nw_send_to(nw_get_socket(), _name, _data);
}

function nw_send_to(_socket, _name, _data) {
	assert_is_not_undefined(_socket);
	assert_is_string(_name);
	global.nwNetworkManager.nwSend(_socket, _name, _data);
}

function nw_broadcast(_name, _data) {
	assert_is_string(_name);
	assert_is_true(nw_is_server());
	global.nwNetworkManager.nwSendBroadcast(_name, _data);
}

function nw_subscribe_connect(_fn, _args) {
	var sid = global.nwNetworkManager.evSubscribe(EV_SOCKET_CONNECT, _fn, _args);
	return sid;
}

function nw_subscribe_disconnect(_fn, _args) {
	var sid = global.nwNetworkManager.evSubscribe(EV_SOCKET_DISCONNECT, _fn, _args);
	return sid;
}

function nw_subscribe_receive(_name, _fn, _args) {
	assert_is_string(_name);
	var sid = global.nwNetworkManager.evSubscribe("recv-"+_name, _fn, _args);
	return sid;
}

function nw_subscription_destroy(_subscription) {
	assert_is_number(_subscription);
	global.nwNetworkManager.unsubscribe(_subscription);
}
