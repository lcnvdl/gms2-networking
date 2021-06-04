draw_set_color(c_white);
	
if(nw_is_server()) {
	draw_text(16, 16, server_mode_description);
}
else if (nw_is_client()) {
	draw_text(16, 16, client_mode_description);
}
else {
	draw_text(16, 16, waiting_mode_description);
}
