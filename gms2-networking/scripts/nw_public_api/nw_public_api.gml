function nw_add_sender(instance, uuid) {
	global.nwNetworkManager.nwRegisterObjectAsSyncSender(instance, uuid);
}

function nw_get_senders_mgr() {
	return global.nwNetworkManager.getSendersManager();	
}

function nw_get_sender(uuid) {
	return global.nwNetworkManager.getSendersManager().Get(uuid);
}
