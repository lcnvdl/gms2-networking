draw_set_color(c_white);
draw_set_halign(fa_right);

draw_text(room_width - 16, 16, "Global Score: " + string(global.globalScore));

draw_text(room_width - 16, 32, "Highscores Table: ");
line = 0;
struct_foreach(global.highscoreTable, function(v, k) {
	line++;
	draw_text(room_width - 100, 32 + 16 * line, string(v));
	draw_text(room_width - 16, 32 + 16 * line, k);
});

draw_set_halign(fa_left);
