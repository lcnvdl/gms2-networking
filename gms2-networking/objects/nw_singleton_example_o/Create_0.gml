randomText = "Hi!";

if (nw_is_server()) {
	var _uuid = nw_add_empty_sender(id, "singleton_example");
	var sender = nw_get_sender(_uuid);
	
	sender.AddSyncVarText("randomText");
	
	alarm[0] = room_speed;
}
else {
	nw_singleton_receiver(id, "singleton_example");	
}
