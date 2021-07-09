event_inherited();

if (nw_is_online()) {
	//	Step 1
	if (!instance_exists(rpc_example_o)) {
		instance_create_layer(0, 0, layer, rpc_example_o);
	}
	//	Step 2
	else if (!instance_exists(rpc_counter_example_o) && nw_is_client()) {
		var counter = instance_create_layer(0, 0, layer, rpc_counter_example_o);
		counter.startAsPlayer();
	}
}
