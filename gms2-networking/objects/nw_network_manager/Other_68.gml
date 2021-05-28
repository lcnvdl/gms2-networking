if (serverMode) {
	nwManageSocketServerEvent(async_load);
}
else {
	nwManageSocketClientEvent(async_load);	
}
