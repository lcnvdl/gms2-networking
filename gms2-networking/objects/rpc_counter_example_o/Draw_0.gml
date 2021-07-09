draw_set_color(color);
draw_set_halign(x <= room_width/2 ? fa_left : fa_right);
if (isPlayer) {
	if (isLoading) {
		draw_text(x, y, "Loading...");
	}
	else {
		draw_text(x, y, "Counter (me): " + string(counter));
	}
}
else {
	draw_text(x, y, "Counter: " + string(counter));
}
draw_set_color(c_white);
draw_set_halign(fa_left);