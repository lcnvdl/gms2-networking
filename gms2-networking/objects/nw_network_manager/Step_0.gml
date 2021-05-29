//	FPS
actual_delta = delta_time/1000000;
_dt = actual_delta;

if(serverSocket < 0) {
	if(keyboard_check_pressed(vk_f3)) {
		selectedEngine = ((selectedEngine + 1) mod 2);	
	}
	
	if (keyboard_check_pressed(ord("B"))) {
		try {
			_createEngineInstance();
			serverSocket = engine.connect(networkSettings.ip, networkSettings.port);
			serverMode = false;
			evCall("client-connect");
		}
		catch(err) {
			show_error(err, false);
			serverSocket = -1;
		}
	}
	else if (keyboard_check_pressed(ord("C"))) {
		try {
			_createEngineInstance();
			serverSocket = engine.serve(networkSettings.port);
			serverMode = true;
			evCall("server-connect");
		}
		catch(err) {
			show_error(err, false);
			serverSocket = -1;
		}
	}
	
	offline = false;
}
else {
	if (!is_undefined(engine.evStep)) {
		engine.evStep(serverSocket, sendBuffer, function(asyncLoad) {
			if (global.nwNetworkManager.serverMode) {
				nwManageSocketServerEvent(asyncLoad);
			}
			else {
				nwManageSocketClientEvent(asyncLoad);	
			}
		});
	}
}