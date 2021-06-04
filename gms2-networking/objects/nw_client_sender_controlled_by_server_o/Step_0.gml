x = damp(x, xTarget, 1);
y = damp(y, yTarget, 1);

if (nw_is_server()) {
	if(lastCommandBy == "client") {
		if (distance_to_point(xTarget, yTarget) < 2) {
			//	If the client reach the goal
			if(!_isRunningServerAction) {
				xTarget = irandom(room_width - 64) + 32;
				yTarget = irandom(room_height - 64) + 32;
			
				_lastXTarget = xTarget;
				_lastYTarget = yTarget;
				
				_isRunningServerAction = true;
			}
			//	If the server reach the goal
			else {
				lastCommandBy = "server";
				
				_isRunningServerAction = false;
			}
		}
		
	}
	else if(!_isRunningServerAction) {
		//	If the client changed the goal
		if (_lastXTarget != xTarget || _lastYTarget != yTarget) {
			
			if (!is_undefined(_lastXTarget)) {
				lastCommandBy = "client";
			}
			
			_lastXTarget = xTarget;
			_lastYTarget = yTarget;
		}
	}
}