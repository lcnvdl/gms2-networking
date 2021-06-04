if(!nw_is_online()) {
	//if(keyboard_check_pressed(vk_f3)) {
	//	selectedEngine = ((selectedEngine + 1) mod 2);	
	//}
	
	if (keyboard_check_pressed(ord("B"))) {
		nw_start_client();
	}
	else if (keyboard_check_pressed(ord("C"))) {
		nw_start_server();
	}
}