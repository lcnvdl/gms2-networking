function nw_start_client() {
	return global.nwNetworkManager.startClient();	
}

function nw_start_server() {
	return global.nwNetworkManager.startServer();	
}

function nw_configure(ip, port) {
	global.nwNetworkManager.networkSettings.ip = ip;
	global.nwNetworkManager.networkSettings.port = port;
}

function nw_add_sender(instance, _uuid) {
	return global.nwNetworkManager.nwRegisterObjectAsSyncSender(instance, _uuid);
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
