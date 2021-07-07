draw_set_color(c_white);
draw_text(16, 64, "Press S to send a RPC call");

if(is_undefined(currentOsVersion)) {
	return;	
}

draw_text(16, 96, string_replace_all(json_stringify(currentOsVersion), ",", ",\n"));