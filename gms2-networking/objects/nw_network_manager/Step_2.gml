/// @description Updates the senders and receivers

if(serverSocket >= 0) {
	if(lastSync <= 0) {
		_sendersMgr.Update();
		lastSync = syncDelay;
	}
	else {
		lastSync -= _dt; 	
	}
	
	_receiversMgr.Update();

	//	Follow camera
	if(nwCamera != noone && !serverMode && autoSendCameraLocation) {
		if (autoSendWatchPoint == -1) {
			engine.send(sendBuffer, 
				serverSocket, 
				NwMessageType.syncClientLocationCreate, 
				{ 
					Name: "nwCamera",
					X: nwCamX, 
					Y: nwCamY,
					Range: clientRange
				});	
			autoSendWatchPoint = 0;
			nwCamX = nwCamera.x;
			nwCamY = nwCamera.y;
		}
		else if (autoSendWatchPoint == 1) {
			if(point_distance(nwCamX, nwCamY, nwCamera.x, nwCamera.y) > 16) {
				engine.send(sendBuffer, 
					serverSocket, 
					NwMessageType.syncClientLocationUpdate, 
					{ 
						Name: "nwCamera",
						X: nwCamX, 
						Y: nwCamY 
					});
				nwCamX = nwCamera.x;
				nwCamY = nwCamera.y;
			}
		}
	}
}

