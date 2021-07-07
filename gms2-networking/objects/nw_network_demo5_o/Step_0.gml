event_inherited();

if (nw_is_online()) {
	if (!instance_exists(rpc_example_o)) {
		instance_create_layer(0, 0, layer, rpc_example_o);
	}
}
