if (serverMode) {
	_manageSocketServerEvent(async_load);
}
else {
	_manageSocketClientEvent(async_load);	
}
