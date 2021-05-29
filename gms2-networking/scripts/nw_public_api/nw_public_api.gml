function nw_add_sender(instance, uuid) {
	global.nwNetworkManager.nwRegisterObjectAsSyncSender(instance, uuid);
}

function nw_add_receiver(instance, uuid) {
	global.nwNetworkManager.nwRegisterObjectAsSyncReceiver(instance, uuid);	
}

function nw_get_senders_mgr() {
	return global.nwNetworkManager.getSendersManager();	
}

function nw_get_sender(uuid) {
	return global.nwNetworkManager.getSendersManager().Get(uuid);
}

function nw_set_network_engine_factory(_function) {
	global.nwNetworkManagerFactory = _function;	
}

function nw_is_server() {
	return global.nwNetworkManager.serverMode;
}

function nw_is_client() {
	return !nw_is_server();	
}