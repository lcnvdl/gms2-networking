function nwEnsureEngine() {
	if (!variable_global_exists("nwNetworkManager")) {
		if (!instance_exists(nw_network_manager)) {
			global.nwNetworkManager = instance_create_depth(0, 0, 0, nw_network_manager);	
		}
	}
}