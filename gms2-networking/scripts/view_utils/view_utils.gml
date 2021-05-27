function fixedX(offset) {
	return camera_get_view_x(view_camera[0]) + offset;
}

function fixedRight(offset) {
	return fixedX(offset) + camera_get_view_width(view_camera[0]);
}

function fixedY(offset) {
	return camera_get_view_y(view_camera[0]) + offset;
}

function viewW() {
	return camera_get_view_width(view_camera[0]);	
}

function viewH() {
	return camera_get_view_height(view_camera[0]);	
}