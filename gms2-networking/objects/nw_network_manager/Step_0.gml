//	FPS
actual_delta = delta_time/1000000;
_dt = actual_delta;

//	Receive events from sync networking engines
if(serverSocket >= 0) {
	if (!is_undefined(engine.evStep)) {
		engine.evStep(serverSocket, sendBuffer, function(asyncLoad) {
			if (global.nwNetworkManager.serverMode) {
				global.nwNetworkManager._manageSocketServerEvent(asyncLoad);
			}
			else {
				global.nwNetworkManager._manageSocketClientEvent(asyncLoad);	
			}
		});
	}
}
