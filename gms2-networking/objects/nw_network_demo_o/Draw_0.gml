draw_set_color(c_white);
	
if(nw_is_server()) {
	draw_text(16, 16, "Server Mode - Click to create balls");
}
else if (nw_is_client()) {
	draw_text(16, 16, "Client Mode");
}
else {
	draw_text(16, 16, "Waiting for connection. C = Server, B = Client.");
}