randomText = "";

repeat(irandom_range(2, 6)) {
	randomText += chr(irandom(128));	
}

alarm[0] = room_speed;