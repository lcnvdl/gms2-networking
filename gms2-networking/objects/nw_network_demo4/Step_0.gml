// Inherit the parent event
event_inherited();

if (nw_is_online()) {
	if (!instance_exists(nw_singleton_example_o)) {
		instance_create_layer(0, 0, layer, nw_singleton_example_o);
	}
}
