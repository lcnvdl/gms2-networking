draw_set_color(c_white);

if(nw_is_server()) {
	draw_text(16, 64, "Press S to send a RPC self-call\nPress D to send a RPC broadcast");
}
else {
	draw_text(16, 64, "Press S to send a RPC call");
}

if(is_undefined(currentOsVersion)) {
	return;	
}

draw_set_color(c_aqua);
draw_text(16, 128, string_replace_all(json_stringify(currentOsVersion), ",", ",\n"));
draw_set_color(c_white);