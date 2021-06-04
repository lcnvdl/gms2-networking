if (isPlayer && lastCommandBy != "client") {
	if (distance_to_point(xTarget, yTarget) < 2) {
		xTarget = mouse_x;
		yTarget = mouse_y;
	
		lastCommandBy = "client";
	}
}