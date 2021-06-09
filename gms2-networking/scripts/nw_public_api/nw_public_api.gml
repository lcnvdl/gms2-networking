function nw_start_client() {
	return global.nwNetworkManager.startClient();	
}

function nw_start_server() {
	return global.nwNetworkManager.startServer();	
}

function nw_configure(ip, port) {
	assert_is_string(ip);
	assert_is_number(port);
	
	global.nwNetworkManager.networkSettings.ip = ip;
	global.nwNetworkManager.networkSettings.port = port;
}

function nw_add_sender(instance, _uuid) {
	return global.nwNetworkManager.nwRegisterObjectAsSyncSender(instance, _uuid);
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

function nw_subscribe_receive(_name, _fn, _args) {
	assert_is_string(_name);
	var sid = global.nwNetworkManager.evSubscribe("recv-"+_name, _fn, _args);
	return sid;
}

function nw_subscription_destroy(_subscription) {
	assert_is_number(_subscription);
	global.nwNetworkManager.unsubscribe(_subscription);
}
