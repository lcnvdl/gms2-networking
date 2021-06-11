/// @description Follow the mouse

if(isPlayer) {
	x = min(room_width-50, max(50, damp(x, mouse_x, 100 * global.nwNetworkManager._dt)));
	y = min(room_height-50, max(50, damp(y, mouse_y, 100 * global.nwNetworkManager._dt)));
}
