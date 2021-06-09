// Inherit the parent event
event_inherited();

if (nw_is_online()) {
	if (!instance_exists(nw_chat_o)) {
		instance_create_layer(x, y, layer, nw_chat_o);
	}
}
