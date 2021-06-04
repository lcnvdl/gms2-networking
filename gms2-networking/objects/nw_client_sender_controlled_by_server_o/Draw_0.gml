draw_self();

//	Draw name
if (nw_is_client()) {
	if (isPlayer) {
		if (lastCommandBy == "client") {
			draw_set_color(c_lime);
		}
		else {
			draw_set_color(c_aqua);	
			draw_text(16, room_height-64, "YOUR TURN! CLICK ANYWHERE");
		}
		draw_text(x, y - sprite_height, name + " (you)");
	}
	else {
		if (lastCommandBy == "client") {
			draw_set_color(c_gray);
		}
		else {
			draw_set_color(c_olive);	
		}
		draw_text(x, y - sprite_height, name);
	}
}
else {
	if (lastCommandBy == "client") {
		draw_set_color(c_gray);
	}
	else {
		draw_set_color(c_aqua);	
	}
	
	if(_isRunningServerAction) {
		draw_text(x, y - sprite_height, name + " **WALKING**");
	}
	else {
		draw_text(x, y - sprite_height, name);
	}
}

//	Draw HP
draw_set_color(c_red);
draw_text(x, y - sprite_height, "\nHP: " + string(hp));

//	Reset color
draw_set_color(c_white);
