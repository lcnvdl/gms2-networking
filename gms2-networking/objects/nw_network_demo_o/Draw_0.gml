draw_set_color(c_white);
	
if(nw_is_server()) {
	draw_text(16, 16, "Click to create balls");
}
else {
	draw_text(16, 16, "Waiting for connection. C = Server, B = Client.");
}