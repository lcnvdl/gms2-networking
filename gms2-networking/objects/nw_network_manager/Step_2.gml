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
	if(nwCamera != noone) {
		if(point_distance(nwCamX, nwCamY, nwCamera.x, nwCamera.y) > 16) {
			engine.send(sendBuffer, serverSocket, NwMessageType.syncClientLocation, { X: nwCamX, Y: nwCamY });	
			nwCamX = nwCamera.x;		
			nwCamY = nwCamera.y;
		}
	}
}
