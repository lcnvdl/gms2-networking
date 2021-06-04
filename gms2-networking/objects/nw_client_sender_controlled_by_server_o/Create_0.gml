lastCommandBy = "server";

xTarget = x;
yTarget = y;

name = "unnamed";

hp = 10;

isPlayer = false;

if (nw_is_client()) {
	alarm[0] = 1;
}
else {
	_lastXTarget = undefined;
	_lastYTarget = undefined;
	_isRunningServerAction = false;
}