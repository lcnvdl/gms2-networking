try {
	if (serverMode) {
		_manageSocketServerEvent(async_load);
	}
	else {
		_manageSocketClientEvent(async_load);	
	}
}
catch(err) {
	show_debug_message("An error has occurred");	
}